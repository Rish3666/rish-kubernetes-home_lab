#!/usr/bin/env bash
# bootstrap.sh — One-command homelab setup for a fresh distro install
# Usage: sudo ./bootstrap.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
STORAGE_DEV="/dev/sdb"
STORAGE_MOUNT="/mnt/storage"
K3S_VERSION="v1.36.2"
TAILSCALE_HOST="rishlab"
DOMAIN="lab.local"
PLAYIT_SECRET="419a5040e19d2c6342a1f69134fce6dfe215477ebfad77631cd9867122f19e5c"

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'
log()  { echo -e "${CYAN}[bootstrap]${RESET} $*"; }
ok()   { echo -e "${GREEN}[ok]${RESET} $*"; }
warn() { echo -e "${YELLOW}[warn]${RESET} $*"; }
err()  { echo -e "${RED}[err]${RESET} $*" >&2; }

# ── Preflight ────────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  err "Must run as root (use sudo)."
  exit 1
fi

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

run_quiet() {
  "$@" >/dev/null 2>&1
}

# ── Step 1: System Preparation ───────────────────────────────────────────────
system_prep() {
  log "Step 1/11: Installing system packages..."
  local distro
  distro=$(detect_distro)

  case "$distro" in
    debian|ubuntu)
      apt-get update -qq
      apt-get install -y -qq curl git ufw htop iotop unzip ca-certificates gnupg lsb-release
      ;;
    fedora)
      dnf install -y curl git ufw htop iotop unzip ca-certificates
      ;;
    arch|manjaro)
      pacman -Sy --noconfirm curl git ufw htop iotop unzip ca-certificates
      ;;
    *)
      warn "Unknown distro '$distro'. Install curl, git, sudo manually."
      ;;
  esac

  swapoff -a 2>/dev/null || true
  sed -i '/swap/d' /etc/fstab 2>/dev/null || true
  ok "System packages installed, swap disabled."
}

# ── Step 2: Storage Mount ────────────────────────────────────────────────────
setup_storage() {
  log "Step 2/11: Setting up storage..."

  if mountpoint -q "$STORAGE_MOUNT"; then
    ok "Storage already mounted at $STORAGE_MOUNT"
    return
  fi

  if [[ ! -b "$STORAGE_DEV" ]]; then
    warn "Storage device $STORAGE_DEV not found. Skipping mount."
    return
  fi

  mkdir -p "$STORAGE_MOUNT"

  local part=""
  if [[ -b "${STORAGE_DEV}1" ]]; then
    part="${STORAGE_DEV}1"
  elif [[ -b "${STORAGE_DEV}p1" ]]; then
    part="${STORAGE_DEV}p1"
  elif [[ -b "${STORAGE_DEV}2" ]]; then
    part="${STORAGE_DEV}2"
  elif [[ -b "${STORAGE_DEV}p2" ]]; then
    part="${STORAGE_DEV}p2"
  else
    warn "No partition found on $STORAGE_DEV. Formatting as ext4..."
    echo "n\np\n1\n\n\nw" | fdisk "$STORAGE_DEV"
    part="${STORAGE_DEV}1"
    mkfs.ext4 -F "$part"
  fi

  local fstype
  fstype=$(blkid -s TYPE -o value "$part" 2>/dev/null || echo "ext4")
  mount "$part" "$STORAGE_MOUNT"

  if ! grep -q "$STORAGE_MOUNT" /etc/fstab; then
    echo "UUID=$(blkid -s UUID -o value "$part")  $STORAGE_MOUNT  $fstype  defaults,nofail  0  2" >> /etc/fstab
  fi

  mkdir -p "$STORAGE_MOUNT"/{minecraft,music,navidrome,nextcloud,backups}
  ok "Storage mounted at $STORAGE_MOUNT with directories created."
}

# ── Step 3: Docker ───────────────────────────────────────────────────────────
setup_docker() {
  log "Step 3/11: Installing Docker..."

  if command -v docker &>/dev/null; then
    ok "Docker already installed."
    return
  fi

  local distro
  distro=$(detect_distro)
  case "$distro" in
    debian|ubuntu)
      curl -fsSL https://get.docker.com | bash
      ;;
    fedora)
      dnf install -y docker docker-compose-plugin
      systemctl enable --now docker
      ;;
    arch|manjaro)
      pacman -Sy --noconfirm docker docker-compose-plugin
      systemctl enable --now docker
      ;;
    *)
      curl -fsSL https://get.docker.com | bash
      ;;
  esac

  usermod -aG docker "$SUDO_USER" 2>/dev/null || true
  ok "Docker installed. User '$SUDO_USER' added to docker group (re-login to apply)."
}

# ── Step 4: K3s ──────────────────────────────────────────────────────────────
setup_k3s() {
  log "Step 4/11: Installing K3s..."

  if command -v k3s &>/dev/null; then
    ok "K3s already installed."
    return
  fi

  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="$K3S_VERSION" sh -
  mkdir -p "$HOME/.kube"
  cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
  chown "$SUDO_USER:$SUDO_USER" "$HOME/.kube/config" 2>/dev/null || true
  chmod 600 "$HOME/.kube/config" 2>/dev/null || true
  export KUBECONFIG="$HOME/.kube/config"

  log "Waiting for node to be Ready..."
  for i in $(seq 1 60); do
    if kubectl get nodes 2>/dev/null | grep -q Ready; then
      ok "K3s node is Ready."
      return
    fi
    sleep 2
  done
  warn "K3s node not Ready after 120s. Check with: kubectl get nodes"
}

# ── Step 5: Helm ─────────────────────────────────────────────────────────────
setup_helm() {
  log "Step 5/11: Installing Helm..."

  if command -v helm &>/dev/null; then
    ok "Helm already installed."
    return
  fi

  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
  helm repo add nextcloud https://nextcloud.github.io/helm/ 2>/dev/null || true
  helm repo update 2>/dev/null || true
  ok "Helm installed with repos added."
}

# ── Step 6: Databases ────────────────────────────────────────────────────────
setup_databases() {
  log "Step 6/11: Deploying databases..."

  kubectl create namespace databases 2>/dev/null || true

  if kubectl get statefulset -n databases mariadb 2>/dev/null | grep -q mariadb; then
    ok "MariaDB already deployed."
  else
    log "Deploying MariaDB..."
    helm upgrade --install mariadb bitnami/mariadb -n databases \
      --set auth.rootPassword=ChangeRootPassword123! \
      --set auth.database=nextcloud \
      --set auth.username=nextcloud \
      --set auth.password=ChangeNextcloudPassword123! \
      --set primary.persistence.size=20Gi \
      --set primary.resources.requests.cpu=100m \
      --set primary.resources.requests.memory=256Mi \
      --set primary.resources.limits.cpu=1000m \
      --set primary.resources.limits.memory=1Gi \
      --set architecture=standalone \
      --wait --timeout 5m
    ok "MariaDB deployed."
  fi

  if kubectl get statefulset -n databases redis-master 2>/dev/null | grep -q redis-master; then
    ok "Redis already deployed."
  else
    log "Deploying Redis..."
    helm upgrade --install redis bitnami/redis -n databases \
      --set auth.enabled=true \
      --set auth.password=YourStrongRedisPassword123! \
      --set master.persistence.size=5Gi \
      --set master.resources.requests.cpu=50m \
      --set master.resources.requests.memory=128Mi \
      --set master.resources.limits.cpu=500m \
      --set master.resources.limits.memory=512Mi \
      --set replica.replicaCount=0 \
      --wait --timeout 5m
    ok "Redis deployed."
  fi
}

# ── Step 7: Applications ─────────────────────────────────────────────────────
setup_apps() {
  log "Step 7/11: Deploying applications..."

  # Navidrome
  if [[ -d "$REPO_DIR/charts/navidrome" ]]; then
    if kubectl get deployment -n navidrome navidrome 2>/dev/null | grep -q navidrome; then
      ok "Navidrome already deployed."
    else
      log "Deploying Navidrome..."
      kubectl create namespace navidrome 2>/dev/null || true
      helm upgrade --install navidrome "$REPO_DIR/charts/navidrome" -n navidrome --wait --timeout 3m
      ok "Navidrome deployed."
    fi
  else
    warn "Navidrome chart not found at charts/navidrome. Skipping."
  fi

  # Nextcloud
  if kubectl get deployment -n nextcloud nextcloud 2>/dev/null | grep -q nextcloud; then
    ok "Nextcloud already deployed."
  else
    log "Deploying Nextcloud..."
    kubectl create namespace nextcloud 2>/dev/null || true

    cat > /tmp/nextcloud-values.yaml << 'VALUES'
nextcloud:
  host: rishlab.tailb96c63.ts.net
  adminUser: admin
  adminPassword: Rish@363636
internalDatabase:
  enabled: false
externalDatabase:
  enabled: true
  type: mysql
  host: mariadb.databases.svc.cluster.local
  database: nextcloud
  user: nextcloud
  password: ChangeNextcloudPassword123!
redis:
  enabled: true
  host: redis-master.databases.svc.cluster.local
  port: 6379
  password: YourStrongRedisPassword123!
ingress:
  enabled: true
  className: traefik
  hosts:
    - host: rishlab.tailb96c63.ts.net
      paths:
        - path: /
          pathType: Prefix
persistence:
  enabled: true
  existingClaim: nextcloud-data
nextcloud:
  configs:
    ratelimit.config.php: |-
      <?php
      $CONFIG = [
        'ratelimit.enabled' => 'false',
        'auth.bruteforce.protection.enabled' => 'false',
      ];
    overwriteprotocol.config.php: |-
      <?php
      $CONFIG = [
        'overwriteprotocol' => 'https',
      ];
resources:
  requests:
    cpu: 100m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi
VALUES

    helm upgrade --install nextcloud oci://registry-1.docker.io/nextcloud/nextcloud \
      -n nextcloud -f /tmp/nextcloud-values.yaml --wait --timeout 10m
    ok "Nextcloud deployed."
  fi

  # Glance
  if [[ -d "$REPO_DIR/charts/glance" ]]; then
    if kubectl get deployment -n glance glance 2>/dev/null | grep -q glance; then
      ok "Glance already deployed."
    else
      log "Deploying Glance..."
      kubectl create namespace glance 2>/dev/null || true
      helm upgrade --install glance "$REPO_DIR/charts/glance" -n glance --wait --timeout 3m
      ok "Glance deployed."
    fi
  else
    warn "Glance chart not found at charts/glance. Skipping."
  fi
}

# ── Step 8: Networking ───────────────────────────────────────────────────────
setup_networking() {
  log "Step 8/11: Configuring networking..."

  # /etc/hosts entries
  for host in glance navidrome nextcloud; do
    if ! grep -q "${host}.${DOMAIN}" /etc/hosts 2>/dev/null; then
      echo "192.168.0.250  ${host}.${DOMAIN}" >> /etc/hosts
    fi
  done
  ok "/etc/hosts entries created."

  # Tailscale Serve
  if command -v tailscale &>/dev/null; then
    if tailscale status 2>/dev/null | grep -q "$TAILSCALE_HOST"; then
      tailscale serve --bg --https 4443 http://glance.glance:8080 2>/dev/null || true
      tailscale serve --bg --https 4533 http://navidrome.navidrome:4533 2>/dev/null || true
      tailscale serve --bg --https 8443 http://nextcloud.nextcloud:8080 2>/dev/null || true
      ok "Tailscale Serve configured for Glance (4443), Navidrome (4533), Nextcloud (8443)."
    else
      warn "Tailscale not logged in. Run 'sudo tailscale up' first."
    fi
  else
    warn "Tailscale not installed. Install from https://tailscale.com/download"
  fi
}

# ── Step 9: Minecraft ────────────────────────────────────────────────────────
setup_minecraft() {
  log "Step 9/11: Setting up Minecraft..."

  local mc_dir="$REPO_DIR/apps/minecraft-docker"
  if [[ -f "$mc_dir/docker-compose.yml" ]]; then
    ok "Minecraft Docker setup already exists."
    return
  fi

  mkdir -p "$mc_dir" "$STORAGE_MOUNT/minecraft"

  cat > "$mc_dir/docker-compose.yml" << 'YML'
services:
  minecraft:
    image: itzg/minecraft-server:java21
    container_name: minecraft
    restart: "no"
    ports:
      - "25565:25565"
      - "30065:25565"
    environment:
      EULA: "TRUE"
      TYPE: FABRIC
      VERSION: "1.21.11"
      FABRIC_LOADER_VERSION: "0.18.4"
      MEMORY: "6G"
      MODE: survival
      DIFFICULTY: normal
      MAX_PLAYERS: "10"
      VIEW_DISTANCE: "24"
      SIMULATION_DISTANCE: "16"
      MOTD: "rishlab - Fabric 1.21.11"
      ONLINE_MODE: "FALSE"
      ENABLE_AUTOPAUSE: "FALSE"
      OVERRIDE_SERVER_PROPERTIES: "TRUE"
      REMOVE_OLD_MODS: "FALSE"
      TZ: Asia/Kolkata
    volumes:
      - /mnt/storage/minecraft:/data
YML

  ok "Minecraft docker-compose.yml created at $mc_dir"
}

# ── Step 10: Playit ──────────────────────────────────────────────────────────
setup_playit() {
  log "Step 10/11: Setting up Playit tunnel..."

  if command -v playit &>/dev/null; then
    ok "Playit already installed."
    return
  fi

  mkdir -p /opt/playit /etc/playit /var/log/playit
  curl -fsSL https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64.tar.gz \
    -o /tmp/playit.tar.gz
  tar xzf /tmp/playit.tar.gz -C /tmp/
  install -m 755 /tmp/playit-linux-amd64 /opt/playit/playitd

  cat > /etc/playit/playit.toml << 'TOML'
secret_key = "419a5040e19d2c6342a1f69134fce6dfe215477ebfad77631cd9867122f19e5c"
TOML

  cat > /usr/lib/systemd/system/playit.service << 'UNIT'
[Unit]
Description=Playit Agent
Documentation=https://playit.gg
Wants=network-pre.target
After=network-pre.target

[Service]
User=playit
Group=playit
RuntimeDirectory=playit
RuntimeDirectoryMode=0750
LogsDirectory=playit
LogsDirectoryMode=0750
UMask=0007
ExecStart=/opt/playit/playitd --secret-path /etc/playit/playit.toml --socket-path /run/playit/playitd.sock -l /var/log/playit/playit.log
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

  id -u playit &>/dev/null || useradd -r -s /sbin/nologin playit
  chown -R playit:playit /opt/playit /etc/playit /var/log/playit

  systemctl daemon-reload
  systemctl enable playit
  systemctl start playit
  ok "Playit installed, enabled, and started."
}

# ── Step 11: Display Services ────────────────────────────────────────────────
setup_display() {
  log "Step 11/11: Installing display services (disabled by default)..."

  cat > /etc/systemd/system/screenoff.service << 'UNIT'
[Unit]
Description=Turn off console display

[Service]
Type=oneshot
Environment=TERM=linux
ExecStart=/usr/bin/setterm --blank force --powersave powerdown --powerdown 1

[Install]
WantedBy=multi-user.target
UNIT

  cat > /etc/systemd/system/panel-off.service << 'UNIT'
[Unit]
Description=Power off internal display panel via fbdev DPMS

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 4 > /sys/class/graphics/fb0/blank; echo 4 > /sys/class/backlight/intel_backlight/bl_power'

[Install]
WantedBy=multi-user.target
UNIT

  systemctl daemon-reload
  ok "Display services installed (disabled by default). Enable with: sudo systemctl enable panel-off.service"
}

# ── Summary ──────────────────────────────────────────────────────────────────
print_summary() {
  log "── Bootstrap Complete ──"
  echo ""
  echo -e "  ${GREEN}Next steps:${RESET}"
  echo "  1. Re-login or run 'newgrp docker' for Docker group to take effect"
  echo "  2. Start Minecraft:  cd apps/minecraft-docker && ./start.sh"
  echo "  3. Visit Glance:     https://rishlab.tailb96c63.ts.net:4443"
  echo "  4. Visit Navidrome:  https://rishlab.tailb96c63.ts.net:4533"
  echo "  5. Visit Nextcloud:  https://rishlab.tailb96c63.ts.net:8443"
  echo ""
  echo -e "  ${YELLOW}Remember to update default passwords in values files.${RESET}"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  log "Starting RishLab homelab bootstrap..."
  echo ""

  system_prep
  setup_storage
  setup_docker
  setup_k3s
  setup_helm
  setup_databases
  setup_apps
  setup_networking
  setup_minecraft
  setup_playit
  setup_display
  print_summary
}

main "$@"
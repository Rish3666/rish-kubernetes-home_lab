# Bootstrap

> **One-command setup for a fresh distro install.**
> Install Tailscale, then run the bootstrap script.

This note documents what the [[bootstrap.sh]] script does and how to use it.

---

## Usage

```bash
# 1. Install Tailscale
curl -sfL https://tailscale.com/install.sh | sh
sudo tailscale up

# 2. Clone the repo
git clone https://github.com/Rish3666/rish-kubernetes-home_lab.git
cd rish-kubernetes-home_lab

# 3. Run bootstrap
sudo ./bootstrap.sh
```

Or in one shot from a fresh install:

```bash
curl -sfL https://tailscale.com/install.sh | sh && \
sudo tailscale up && \
git clone https://github.com/Rish3666/rish-kubernetes-home_lab.git && \
cd rish-kubernetes-home_lab && \
sudo ./bootstrap.sh
```

---

## What it does

The bootstrap script automates everything documented in these notes:

### 1. System Preparation
- Detects OS/distro (Debian/Ubuntu, Fedora, Arch)
- Installs essential packages (curl, git, sudo, etc.)
- Disables swap (recommended for K3s)

### 2. Hardware Prep
- Detects and mounts the 1TB HDD (`/dev/sdb`) to `/mnt/storage`
- Creates required directories: `minecraft/`, `music/`, `navidrome/`, `nextcloud/`, `backups/`
- Adds fstab entry for persistent mount

Details: [[Hardware]], [[Storage]]

### 3. Docker
- Installs Docker via official script
- Adds user to `docker` group
- Sets up Docker Compose

### 4. K3s
- Installs K3s v1.36.2 (single-node)
- Sets up kubeconfig for non-root user
- Waits for node to be Ready

Details: [[Kubernetes]]

### 5. Helm
- Installs Helm binary
- Adds Bitnami, Nextcloud, and other repos

### 6. Databases
- Creates `databases` namespace
- Deploys MariaDB via Bitnami Helm chart
- Deploys Redis via Bitnami Helm chart

Details: [[Databases]]

### 7. Applications
- **[[Nextcloud]]** — Deploys via official Helm chart with MariaDB + Redis
- **[[Navidrome]]** — Deploys via local Helm chart with PVs for music + data
- **[[Glance]]** — Deploys via local Helm chart with monitoring config

### 8. Networking
- Configures [[Networking#Traefik]] ingress (Traefik comes with K3s)
- Sets up [[Networking#Tailscale]] Serve for all services
- Creates local `/etc/hosts` entries

### 9. Minecraft
- Creates `apps/minecraft-docker/` directory
- Sets up `docker-compose.yml` for Fabric server
- Configures Playit tunnel

Details: [[Minecraft]], [[Scripts]]

### 10. Playit
- Installs Playit.gg agent
- Copies secret key
- Sets up systemd service (disabled at boot)

### 11. Display Services
- Installs `screenoff.service` and `panel-off.service`
- Both disabled by default — enable manually if needed

Details: [[Scripts#Systemd Services]]

---

## After Bootstrap

1. **Update passwords** in values files (Nextcloud, MariaDB, Redis)
2. **Start Minecraft:** `cd apps/minecraft-docker && ./start.sh`
3. **Verify services:** Visit `https://rishlab.tailb96c63.ts.net:4443` (Glance)
4. **Configure Playit:** Login at playit.gg and claim the tunnel

---

## Re-running

The bootstrap script is **idempotent** — safe to re-run. It skips steps that are already done:
- Doesn't reformat the HDD if already mounted
- Doesn't re-install K3s if already running
- Upgrades Helm charts if already deployed (`helm upgrade --install`)

---

## Debugging

If something fails:
1. Re-run with `bash -x bootstrap.sh 2>&1 | tee bootstrap.log`
2. Check [[Troubleshooting]] for common issues
3. Check `kubectl get pods -A` to see which pods are failing
4. Check `kubectl logs -n <ns> <pod>` for container errors
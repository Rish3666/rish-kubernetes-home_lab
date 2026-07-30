# Bootstrap

> **One-command setup for a fresh distro install.**
> Install Tailscale, clone the repo, then run the bootstrap script.

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

One-shot from a fresh install:

```bash
curl -sfL https://tailscale.com/install.sh | sh && \
sudo tailscale up && \
git clone https://github.com/Rish3666/rish-kubernetes-home_lab.git && \
cd rish-kubernetes-home_lab && \
sudo ./bootstrap.sh
```

---

## What the Script Does

### 1. System Preparation
- Detects distro (Debian/Ubuntu, Fedora, Arch)
- Installs packages: curl, git, ufw, htop, iotop, unzip
- Disables swap (recommended for K3s)

### 2. Storage
- Detects and mounts `/dev/sdb` (1TB HDD) to `/mnt/storage`
- Creates required directories: `minecraft/`, `music/`, `navidrome/`, `nextcloud/`, `backups/`
- Adds fstab entry with UUID for persistent mount

Details: [[Hardware]], [[Storage]]

### 3. Docker
- Installs Docker via official script
- Adds user to `docker` group
- Sets up Docker Compose plugin

### 4. K3s
- Installs K3s v1.36.2 (single-node)
- Sets up kubeconfig for non-root user (`~/.kube/config`)
- Waits for node to be Ready (up to 120s)

> **If `/var` is small (<10 GB):** Symlink `/var/lib/rancher` to storage before installing K3s:
> ```bash
> mkdir -p /mnt/storage/k3s
> ln -sf /mnt/storage/k3s/rancher /var/lib/rancher
> ```

Details: [[Kubernetes]]

### 5. Helm
- Downloads and installs Helm binary
- Adds Bitnami repo
- Adds Nextcloud Helm repo

### 6. Databases
- Creates `databases` namespace
- Deploys MariaDB via Bitnami Helm chart (standalone, 20Gi)
- Deploys Redis via Bitnami Helm chart (standalone, 5Gi)

Details: [[Databases]]

### 7. Applications
- [[Navidrome]] — local Helm chart with PVs for music + data
- [[Nextcloud]] — official Helm chart with MariaDB + Redis
- [[Glance]] — local Helm chart with monitoring config

### 8. Networking
- Creates `/etc/hosts` entries (`glance.lab.local`, `navidrome.lab.local`, `nextcloud.lab.local`)
- Configures Tailscale Serve for Glance (4443), Navidrome (4533), Nextcloud (8443)

### 9. Minecraft
- Creates `docker-compose.yml` for Fabric 1.21.11 server
- Creates mc-status companion container (port 8082)
- Sets up world directory at `/mnt/storage/minecraft`

### 10. Playit
- Downloads and installs Playit agent to `/opt/playit`
- Creates `playit` user and systemd service
- Service is enabled but Minecraft is not auto-started

### 11. Display Services
- Installs `screenoff.service` (console blanking)
- Installs `panel-off.service` (backlight power-off)
- Both disabled by default

---

## After Bootstrap

1. **Update passwords** in values files (Nextcloud, MariaDB, Redis)
2. **Start Minecraft:** `cd apps/minecraft-docker && ./start.sh`
3. **Verify services:** Visit `https://deb-rish.tailb96c63.ts.net:4443` (Glance)
4. **Configure Playit:** Login at playit.gg and claim the tunnel
5. **Set admin password:** Nextcloud initial admin is `admin` with password from values

---

## Idempotency

The bootstrap script is safe to re-run:
- Skips HDD mount if already mounted
- Skips K3s install if already installed
- Uses `helm upgrade --install` so charts are updated if already deployed
- Doesn't overwrite existing minecraft data

---

## Debugging

If something fails:
1. Re-run: `bash -x bootstrap.sh 2>&1 | tee bootstrap.log`
2. Check [[Troubleshooting]] for common issues
3. `kubectl get pods -A` to see which pods are failing
4. `kubectl logs -n <ns> <pod>` for container errors

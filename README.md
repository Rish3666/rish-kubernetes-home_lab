# RishLab — K3s Homelab

Infrastructure-as-code for a single-node [K3s](https://k3s.io/) cluster running on a home server. All apps are deployed via Helm with Tailscale networking, Traefik ingress, and centralized databases.

---

## Prerequisites

| Tool    | Purpose                          | Install                                                         |
|---------|----------------------------------|-----------------------------------------------------------------|
| Linux   | Host OS (tested on Ubuntu 24.04) | —                                                               |
| K3s     | Lightweight Kubernetes           | `curl -sfL https://get.k3s.io \| sh -`                          |
| Helm    | Kubernetes package manager       | `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \| bash` |
| kubectl | Kubernetes CLI                   | Included with K3s (`kubectl` alias set via `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml`) |
| Tailscale | Secure mesh VPN                | `curl -fsSL https://tailscale.com/install.sh \| sh`              |

After installing K3s, export your kubeconfig:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# Add to ~/.bashrc for persistence
```

---

## Repository Layout

```
~/rishlab/
├── apps/                    # Application Helm values & charts
│   ├── nextcloud/           #   Nextcloud values (external DB)
│   └── navidrome/           #   Navidrome local Helm chart
├── databases/               # Centralized shared databases
│   ├── mariadb/             #   MariaDB values
│   └── redis/               #   Redis values
├── backups/                 # Backup configs (planned)
│   ├── restic/
│   └── velero/
├── monitoring/              # Monitoring stack (planned)
│   ├── alloy/
│   ├── grafana/
│   ├── loki/
│   └── prometheus/
├── networking/              # Networking configs (planned)
│   ├── cert-manager/
│   ├── tailscale/
│   └── traefik/
├── storage/                 # Storage configs (planned)
│   ├── longhorn/
│   └── nfs/
├── scripts/                 # Utility scripts
├── docs/                    # Notes and documentation
├── README.md
└── .gitignore
```

---

## Architecture: Centralized Databases

All applications share a single MariaDB and Redis instance in the `databases` namespace. This avoids running a database per app and reduces resource usage on a single-node cluster.

```
┌─────────────────────────────────────────────────────────────┐
│                     databases namespace                     │
│  ┌──────────┐  ┌────────────┐                               │
│  │  MariaDB │  │   Redis    │                               │
│  │  :3306   │  │   :6379    │                               │
│  └────┬─────┘  └─────┬──────┘                               │
│       │              │                                       │
└───────┼──────────────┼───────────────────────────────────────┘
        │              │
        │              │
┌───────┼──────────────┼───────────────────────────────────────┐
│       │              │                                       │
│  ┌────▼────┐  ┌──────▼──────┐                               │
│  │Nextcloud│  │  Navidrome  │                               │
│  └─────────┘  └─────────────┘                               │
│                     apps namespace                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Deployment

### 1. Centralized Databases

Create the `databases` namespace and deploy MariaDB + Redis:

```bash
kubectl create namespace databases

# MariaDB
helm upgrade --install mariadb oci://registry-1.docker.io/bitnamicharts/mariadb \
  -n databases -f databases/mariadb/values.yaml --wait

# Redis
helm upgrade --install redis oci://registry-1.docker.io/bitnamicharts/redis \
  -n databases -f databases/redis/values.yaml --wait
```

Verify they're running:

```bash
kubectl get pods -n databases
```

### 2. Applications

#### Nextcloud

Change admin password first in `apps/nextcloud/values.yaml`:

```yaml
nextcloud:
  username: admin
  password: YourSecurePassword  # ← Change this
```

Then deploy:

```bash
kubectl create namespace nextcloud

helm upgrade --install nextcloud oci://registry-1.docker.io/nextcloud/nextcloud \
  -n nextcloud -f apps/nextcloud/values.yaml --wait
```

**Note:** This config disables the bundled MariaDB and Redis in favor of the centralized ones in the `databases` namespace.

#### Navidrome

Navidrome uses a local Helm chart with `hostPath` PersistentVolumes. First create the data and music directories on the host:

```bash
sudo mkdir -p /mnt/storage/navidrome /mnt/storage/music
sudo chown -R 1000:1000 /mnt/storage/navidrome /mnt/storage/music
```

Adjust paths in `apps/navidrome/values.yaml` if needed:

```yaml
storage:
  music:
    hostPath: /mnt/storage/music   # Your music library path
    size: 100Gi
  data:
    hostPath: /mnt/storage/navidrome
    size: 5Gi
```

Then deploy:

```bash
kubectl create namespace navidrome

helm upgrade --install navidrome ./apps/navidrome \
  -n navidrome
```

---

## Customizing for Your Own Cluster

1. **Change all passwords** — Search the entire repo for placeholder passwords and replace them:
   - `ChangeRootPassword123!` (MariaDB root)
   - `ChangeNextcloudPassword123!` (MariaDB nextcloud user)
   - `YourStrongRedisPassword123!` (Redis)
   - `Rish@363636` (Nextcloud admin)

2. **Update hostnames** — Replace `*.tailb96c63.ts.net` with your own Tailscale MagicDNS suffix or domain in:
   - `apps/nextcloud/values.yaml`
   - Navidrome ingress template (optional — add `host:` field)

3. **Adjust storage paths** — Update `hostPath` in Navidrome PV templates and Nextcloud persistence config to match your server's mount points.

4. **Tweak resources** — CPU/memory requests and limits are conservative for a small server. Adjust based on your hardware.

---

## Networking

### Tailscale + MagicDNS

This cluster uses [Tailscale](https://tailscale.com/) for secure, private networking with MagicDNS. The default Tailscale hostname is `rishlab.tailb96c63.ts.net`. Services are exposed through:

- **Traefik ingress controller** (K3s default, on port 80/443)
- **Tailscale IP** (tailscale0 interface, accessible by any device on your tailnet)

### Exposing Services

| Service    | URL                                         |
|------------|---------------------------------------------|
| Nextcloud  | `http://rishlab.tailb96c63.ts.net`          |
| Navidrome  | `http://music.tailb96c63.ts.net`            |

For `*.tailb96c63.ts.net` subdomains to resolve on all devices (not just the node itself), enable **[Tailscale Serve](https://tailscale.com/kb/1311/serve)** in the admin console or use a reverse proxy.

### Traefik Dashboard

K3s ships with Traefik by default. Access the dashboard:

```bash
kubectl port-forward -n kube-system deployment/traefik 8080:9000
# Open http://localhost:8080/dashboard/
```

---

## Stack Overview

| Component   | Namespace   | Purpose             | Deployment Method        |
|-------------|-------------|---------------------|--------------------------|
| MariaDB     | databases   | Relational DB       | Bitnami Helm chart       |
| Redis       | databases   | Cache / session     | Bitnami Helm chart       |
| Nextcloud   | nextcloud   | File sync & share   | Official Helm chart      |
| Navidrome   | navidrome   | Music streaming     | Local Helm chart (hostPath) |

### Planned Additions

- Authentik — Identity provider / SSO
- Immich — Photo backup
- Jellyfin — Media server
- Paperless-ngx — Document management
- Gitea / Forgejo — Git hosting
- Grafana + Prometheus + Loki — Monitoring & logging
- cert-manager + Let's Encrypt — Automatic TLS
- Longhorn — Distributed block storage
- Harbor — Container registry
- ArgoCD — GitOps deployment

---

## Troubleshooting

### Pod stuck at Init/ContainerCreating

Check persistent volumes exist:

```bash
kubectl get pv,pvc -A
```

For hostPath volumes, verify the directory exists on the node.

### Nextcloud fails to connect to MariaDB

Ensure MariaDB is running and the database/credentials match `externalDatabase` in `apps/nextcloud/values.yaml`:

```bash
kubectl exec -n databases deploy/mariadb -- mysql -u nextcloud -p"$MARIADB_PASSWORD" -e "SHOW DATABASES;"
```

### Navidrome shows "decryption panicked" on login

The password was encrypted with a different key. Use the Navidrome CLI to reset it:

```bash
kubectl exec -n navidrome deploy/navidrome -it -- /app/navidrome user edit --set-password -u <username> --datafolder /data
```

### Tailscale subdomains don't resolve

MagicDNS only resolves the machine hostname (e.g., `rishlab.tailb96c63.ts.net`). For `music.tailb96c63.ts.net` on devices without `tailscale serve`, add a hosts entry:

```bash
# On each client (Linux/Mac)
echo "100.x.x.x music.tailb96c63.ts.net" >> /etc/hosts
```

Or enable Tailscale Serve from the admin console.

---

## License

This is a personal homelab configuration. Feel free to fork and adapt for your own use.

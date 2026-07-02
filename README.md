# RishLab — K3s Homelab

Infrastructure-as-code for my single-node K3s cluster running on a home server, deployed via Helm with Tailscale networking and Traefik ingress.

## Architecture

```
apps/            — Application Helm values & charts (Nextcloud, Navidrome, etc.)
databases/       — Centralized MariaDB & Redis, shared across all apps
monitoring/      — Prometheus, Grafana, Loki, Alloy (planned)
networking/      — Traefik, cert-manager, Tailscale config
storage/         — Longhorn, NFS (planned)
backups/         — Restic, Velero (planned)
scripts/         — Utility scripts
docs/            — Documentation and notes
```

## Prerequisites

- K3s single-node cluster
- Helm CLI
- kubectl with KUBECONFIG pointing to the cluster

## Quick Start

```bash
# Centralized databases
helm upgrade --install mariadb oci://registry-1.docker.io/bitnamicharts/mariadb \
  -n databases --create-namespace -f databases/mariadb/values.yaml

helm upgrade --install redis oci://registry-1.docker.io/bitnamicharts/redis \
  -n databases -f databases/redis/values.yaml

# Apps
helm upgrade --install nextcloud nextcloud/nextcloud \
  -n nextcloud --create-namespace -f apps/nextcloud/values.yaml

helm upgrade --install navidrome ./apps/navidrome \
  -n navidrome --create-namespace
```

## Networking

All services are exposed via Traefik ingress on `*.tailb96c63.ts.net` (Tailscale MagicDNS). Traffic is internal-only — no public internet exposure.

| Service    | URL                                    |
|------------|----------------------------------------|
| Nextcloud  | http://rishlab.tailb96c63.ts.net       |
| Navidrome  | http://music.tailb96c63.ts.net         |

## Stack

| Component   | Purpose              | Namespace   |
|-------------|----------------------|-------------|
| MariaDB     | Centralized database | databases   |
| Redis       | Centralized cache    | databases   |
| Nextcloud   | File sync & share    | nextcloud   |
| Navidrome   | Music streaming      | navidrome   |

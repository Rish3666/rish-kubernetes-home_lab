# Future Plans

## Planned Services

| Service | Purpose | Directory | Priority |
|---------|---------|-----------|----------|
| **Authentik** | SSO / Identity provider | `apps/authentik/` | High |
| **Jellyfin** | Media server (movies/TV) | `apps/jellyfin/` | Medium |
| **Immich** | Photo backup (Google Photos alternative) | `apps/immich/` | High |
| **Paperless-ngx** | Document management | `apps/paperless/` | Medium |
| **Homepage** | Alternative dashboard | `apps/homepage/` | Low |

---

## Monitoring Stack

| Service | Purpose | Directory |
|---------|---------|-----------|
| **Prometheus** | Metrics collection | `monitoring/prometheus/` |
| **Grafana** | Dashboards & visualization | `monitoring/grafana/` |
| **Loki** | Log aggregation | `monitoring/loki/` |
| **Grafana Alloy** | Log/metric collection agent | `monitoring/alloy/` |

---

## Networking

| Service | Purpose | Directory |
|---------|---------|-----------|
| **cert-manager** | Automatic TLS certificates | `networking/cert-manager/` |
| **Tailscale operator** | Native K3s integration | `networking/tailscale/` |
| **Traefik CRDs** | Advanced ingress config | `networking/traefik/` |

---

## Storage

| Service | Purpose | Directory |
|---------|---------|-----------|
| **Longhorn** | Distributed block storage | `storage/longhorn/` |
| **NFS** | Network file share | `storage/nfs/` |

---

## Backups

| Service | Purpose | Directory |
|---------|---------|-----------|
| **Restic** | Encrypted backups to external/cloud | `backups/restic/` |
| **Velero** | Kubernetes backup & restore | `backups/velero/` |

---

## Other Ideas

- **Gitea / Forgejo** — Self-hosted Git hosting
- **Harbor** — Container image registry
- **ArgoCD** — GitOps deployment
- **Migrate Minecraft from Docker Compose → K3s** — Full Kubernetes adoption
- **External access for web services** — Expose Nextcloud/Navidrome via Cloudflare Tunnel or similar
- **Upgrade RAM** — 8GB → 16GB+ (DIMM0 is empty, max 32GB)
- **USB HDD backup** — Mount `/dev/sdc` (1TB WD) for automated backups
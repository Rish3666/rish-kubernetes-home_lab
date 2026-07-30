# Future Plans

> See also: [[Architecture]], [[Bootstrap]]

---

## High Priority

| Service | Purpose | Status |
|---------|---------|--------|
| **Authentik** | SSO for all services | Planned |
| **Immich** | Photo backup (Google Photos replacement) | Planned |

## Medium Priority

| Service | Purpose |
|---------|---------|
| **Jellyfin** | Media server (movies/TV) |
| **Paperless-ngx** | Document management |
| **cert-manager** | Automatic TLS certificates |
| **Monitoring stack** | Prometheus + Grafana + Loki |
| **Headlamp** | Kubernetes web UI |

## Low Priority

| Service | Purpose |
|---------|---------|
| **Longhorn** | Distributed storage |
| **Gitea/Forgejo** | Git hosting |
| **ArgoCD** | GitOps deployment |
| **Migrate Minecraft → K3s** | Full K8s adoption |

## Hardware Upgrades

| Component | Current | Target |
|-----------|---------|--------|
| RAM | 8 GB (1x8GB) | 16-32 GB (add second stick, DIMM0 empty, max 32GB) |
| USB HDD backup | `/dev/sdc` unmounted | Mount for automated backups |

## Infrastructure

- **Automated backups** — script to snapshot PVs
- **Health alerts** — push notifications if services go down
- **Terraform monorepo** — IaC for the whole homelab

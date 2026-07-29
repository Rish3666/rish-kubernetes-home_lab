# Future Plans

> See also: [[Bootstrap]], [[Architecture]]

---

## High Priority

| Service | Purpose | Reason |
|---------|---------|--------|
| [[Bootstrap]] | ✅ Done — one-command setup |
| **Authentik** | SSO for all services | Single sign-on |
| **Immich** | Photo backup | Google Photos replacement |

---

## Medium Priority

| Service | Purpose |
|---------|---------|
| **Jellyfin** | Media server |
| **Paperless-ngx** | Document management |
| **cert-manager** | Automatic TLS |
| **Monitoring stack** | Prometheus + Grafana + Loki |

---

## Low Priority

| Service | Purpose |
|---------|---------|
| **Longhorn** | Distributed storage |
| **Gitea/Forgejo** | Git hosting |
| **ArgoCD** | GitOps |
| **Migrate Minecraft → K3s** | Full K8s adoption |

---

## Hardware Upgrades

- **RAM** → 16GB+ (DIMM0 empty, max 32GB)
- **USB HDD backup** → Mount `/dev/sdc` for automated backups
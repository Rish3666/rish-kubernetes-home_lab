# Storage

## Disk Layout

| Device | Size | Mount | Content |
|--------|------|-------|---------|
| `/dev/sda` (SSD) | 120 GB | `/` | OS, K3s, container images |
| `/dev/sdb` (HDD) | 1 TB | `/mnt/storage` | App data |
| `/dev/sdc` (USB HDD) | 1 TB | (unmounted) | Backup / spare |

---

## HDD Contents (`/mnt/storage`)

```
/mnt/storage/
├── music/                  # Navidrome music library
├── navidrome/              # Navidrome database + cache
├── nextcloud/              # Nextcloud user files
├── minecraft/              # Minecraft world + mods + config
├── backups/                # Backup scripts/data
├── mc_status_server.py     # Minecraft status HTTP server
```

---

## Kubernetes Persistent Volumes

| PV Name | Size | Host Path | Status | Claim |
|---------|------|-----------|--------|-------|
| `navidrome-data-pv` | 5Gi | `/mnt/storage/navidrome` | Bound | navidrome/navidrome-data-pvc |
| `navidrome-music-pv` | 100Gi | `/mnt/storage/music` | Bound | navidrome/navidrome-music-pvc |
| `nextcloud-data-pv` | 256Gi | `/mnt/storage/nextcloud` | Bound | nextcloud/nextcloud-data |
| `minecraft-pv` | 50Gi | `/mnt/storage/minecraft` | Released | (was minecraft/minecraft-pvc) |

All non-system PVs use `Retain` reclaim policy and storage class `manual`.

### Notes
- `local-path` storage class is used for MariaDB (20Gi) and Redis (5Gi) — these use the SSD
- `manual` storage class is used for all hostPath PVs on the HDD
- The Minecraft PV is in `Released` state because its namespace+claim were deleted but the PV was retained via `helm.sh/resource-policy: keep`

---

## Backups

- Backup location: `/mnt/storage/backups/`
- Restic and Velero planned (not yet configured)
- `minecraft_backup_forge_*` files exist from manual backup attempts

---

## Storage Classes

| Name | Provisioner | Reclaim | Used By |
|------|-------------|---------|---------|
| `local-path` | rancher/local-path-provisioner | Delete | MariaDB, Redis |
| `manual` | (none — manually created PVs) | Retain | Navidrome, Nextcloud, Minecraft |
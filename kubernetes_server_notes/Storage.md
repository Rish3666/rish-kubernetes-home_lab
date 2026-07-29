# Storage

> See also: [[Hardware#Storage]], [[Architecture]], [[Bootstrap#Storage Mounts]]

---

## Disk Layout

| Device | Size | Mount | Content |
|--------|------|-------|---------|
| `/dev/sda` (SSD) | 120 GB | `/` | OS, [[Kubernetes]], container images |
| `/dev/sdb` (HDD) | 1 TB | `/mnt/storage` | App data |
| `/dev/sdc` (USB HDD) | 1 TB | (unmounted) | Backup |

---

## HDD Contents

```
/mnt/storage/
├── music/                  # Navidrome music library
├── navidrome/              # Navidrome database + cache
├── nextcloud/              # Nextcloud user files
├── minecraft/              # Minecraft world + mods + config
├── backups/                # Backup scripts/data
```

---

## Kubernetes Persistent Volumes

| PV Name | Size | Host Path | Status | Used By |
|---------|------|-----------|--------|---------|
| `navidrome-data-pv` | 5Gi | `/mnt/storage/navidrome` | Bound | [[Navidrome]] |
| `navidrome-music-pv` | 100Gi | `/mnt/storage/music` | Bound | [[Navidrome]] |
| `nextcloud-data-pv` | 256Gi | `/mnt/storage/nextcloud` | Bound | [[Nextcloud]] |

All non-system PVs use `Retain` reclaim policy and storage class `manual`.

---

## Storage Classes

| Name | Provisioner | Reclaim | Used By |
|------|-------------|---------|---------|
| `local-path` | rancher/local-path-provisioner | Delete | [[Databases]] (MariaDB, Redis) |
| `manual` | (none — manually created) | Retain | Navidrome, Nextcloud |
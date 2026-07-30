# Storage

> See also: [[Hardware#Storage]], [[Architecture]], [[Bootstrap#Storage]]

---

## Disk Layout

| Device | Size | Mount | Content |
|--------|------|-------|---------|
| `/dev/sda` (SSD) | 120 GB | `/` | OS, K3s binaries, container images |
| `/dev/sdb2` (HDD) | 1 TB | `/mnt/storage` | App data |
| `/dev/sdc` (USB HDD) | 1 TB | (unmounted) | Backup |

The HDD at `/dev/sdb2` is mounted by UUID in `/etc/fstab`:
```
UUID=ef4c5fd2-8174-41c1-b05f-3e4cfbdf5091  /mnt/storage  ext4  defaults,nofail  0  2
```

## HDD Contents

```
/mnt/storage/
├── music/                  # Navidrome music library (100Gi PV)
├── navidrome/              # Navidrome database + cache (5Gi PV)
├── nextcloud/              # Nextcloud user files (256Gi PV)
├── minecraft/              # Minecraft world + mods + config
├── backups/                # Backup scripts/data
└── k3s/                    # K3s data (rancher, etcd, images)
    └── rancher/            # Symlinked from /var/lib/rancher
```

## /var Symlink

The `/var` partition is only 4 GB, so K3s data is redirected:
```
/var/lib/rancher → /mnt/storage/k3s/rancher
```

This was set up on fresh install before running K3s to avoid filling `/var`.

## Kubernetes Persistent Volumes

| PV Name | Size | Host Path | Status | Used By |
|---------|------|-----------|--------|---------|
| `navidrome-data-pv` | 5Gi | `/mnt/storage/navidrome` | Bound | [[Navidrome]] |
| `navidrome-music-pv` | 100Gi | `/mnt/storage/music` | Bound | [[Navidrome]] |
| `nextcloud-data-pv` | 256Gi | `/mnt/storage/nextcloud` | Bound | [[Nextcloud]] |

All non-system PVs use `Retain` reclaim policy and storage class `manual`.

## Storage Classes

| Name | Provisioner | Reclaim | Used By |
|------|-------------|---------|---------|
| `local-path` | rancher/local-path-provisioner | Delete | [[Databases]] (MariaDB, Redis) |
| `manual` | (none — manually created) | Retain | Navidrome, Nextcloud |

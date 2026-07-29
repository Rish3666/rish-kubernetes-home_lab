# Navidrome

**Chart:** Local Helm chart (`charts/navidrome`)  
**Namespace:** `navidrome`  
**Image:** `deluan/navidrome:latest`  
**Version:** 0.61.1  
**Status:** Running

> See also: [[Architecture]], [[Storage]], [[Kubernetes]], [[Bootstrap#Navidrome]]

---

## Configuration

| Setting | Value |
|---------|-------|
| Timezone | Asia/Kolkata |
| Music folder | `/music` |
| Data folder | `/data` |
| Image cache size | 500MB |
| Download rate limit | 0 (unlimited) |

---

## Storage

| Volume | Size | Host Path | Purpose |
|--------|------|-----------|---------|
| `navidrome-music-pv` | 100Gi | `/mnt/storage/music` | Music files |
| `navidrome-data-pv` | 5Gi | `/mnt/storage/navidrome` | Database, cache, config |

---

## Service

| Setting | Value |
|---------|-------|
| Type | NodePort |
| Port | 4533 |
| NodePort | 31433 |

---

## Access

| Method | URL |
|--------|-----|
| Internal (Tailscale) | `https://rishlab.tailb96c63.ts.net:4533` |
| Internal (lab.local) | `https://navidrome.lab.local` |
| Direct | `192.168.0.250:31433` |

Details: [[Networking]]
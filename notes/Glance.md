# Glance Dashboard

**Deployment:** Local Helm chart (`charts/glance`)  
**Namespace:** `glance`  
**Image:** `glanceapp/glance` (v0.8.5)  
**Status:** Running

---

## Configuration

| Setting | Value |
|---------|-------|
| Host | `glance.lab.local` |
| Port | 8080 |
| Service type | ClusterIP |
| Timezone | Asia/Kolkata |

### Resources
| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 500m |
| Memory | 128Mi | 256Mi |

---

## Dashboard Layout

### Left Column (full width)
1. **Search** — DuckDuckGo, bangs: `!yt`, `!gh`, `!r`
2. **Server Stats** — Local system (CPU, RAM, disk)
3. **Monitor (Services)** — Uptime tracking for:
   - Navidrome (`http://navidrome.navidrome:4533/app/`)
   - Nextcloud (`http://nextcloud.nextcloud:8080`)
   - Glance itself (`http://glance.glance:8080`)
   - Minecraft (`http://172.17.0.1:8082`)
4. **Hacker News** — Top 10, collapse after 5
5. **YouTube** — Channels: Linus Tech Tips, Jeff Geerling, NetworkChuck, limit 12, grid-cards

### Right Column (small)
1. **Minecraft Status** — Custom API widget querying `http://172.17.0.1:8082`
2. **GitHub Profile** — `https://api.github.com/users/Rish3666`
3. **Recent Commits** — GitHub search `author:Rish3666`

---

## Access

| Method | URL |
|--------|-----|
| Internal (Tailscale) | `https://rishlab.tailb96c63.ts.net:4443` |
| Internal (lab.local) | `https://glance.lab.local` |

---

## Notes

- Runs as non-root (UID 1000)
- Drops all capabilities
- Read-only root filesystem
- Health check: HTTP GET `/` on port 8080
- Mounts host `/proc` and `/sys` for hardware stats
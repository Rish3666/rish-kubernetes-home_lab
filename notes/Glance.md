# Glance Dashboard

**Chart:** Local Helm chart (`charts/glance`)  
**Namespace:** `glance`  
**Image:** `glanceapp/glance` (v0.8.5)  
**Status:** Running

> See also: [[Architecture]], [[Kubernetes]], [[Bootstrap#Glance]]

---

## Configuration

| Setting | Value |
|---------|-------|
| Host | `glance.lab.local` |
| Port | 8080 |
| Service type | ClusterIP |

---

## Dashboard Layout

### Left Column
1. **Search** — DuckDuckGo with bangs
2. **Server Stats** — CPU, RAM, disk
3. **Monitor** — Uptime tracking for [[Navidrome]], [[Nextcloud]], [[Glance]], [[Minecraft]]
4. **Hacker News** — Top 10
5. **YouTube** — Linus Tech Tips, Jeff Geerling, NetworkChuck

### Right Column
1. **Minecraft Status** — Custom API widget
2. **GitHub Profile** — `Rish3666`
3. **Recent Commits** — GitHub search

---

## Access

| Method | URL |
|--------|-----|
| Internal (Tailscale) | `https://rishlab.tailb96c63.ts.net:4443` |
| Internal (lab.local) | `https://glance.lab.local` |

Details: [[Networking]]
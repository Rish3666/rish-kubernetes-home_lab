# Minecraft Server

**Approach:** Docker Compose (not K3s)  
**Container:** `itzg/minecraft-server:java21`  
**Mod loader:** Fabric  
**Version:** 1.21.11  
**Fabric Loader:** 0.18.4  
**Status:** Stopped (start with `./start.sh`)

---

## Container Setup

### Ports
| Port | Purpose |
|------|---------|
| 25565 | Game |
| 30065 | Alternative game port |

### Environment
```yaml
EULA: "TRUE"
TYPE: FABRIC
VERSION: "1.21.11"
FABRIC_LOADER_VERSION: "0.18.4"
MEMORY: "6G"
MODE: survival
DIFFICULTY: normal
MAX_PLAYERS: 10
VIEW_DISTANCE: 24
SIMULATION_DISTANCE: 16
MOTD: "rishlab - Fabric 1.21.11"
ONLINE_MODE: "FALSE"
```

### JVM Flags (Aikar's GC flags)
```
-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch
-XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M
-XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4
-XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90
-XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32
```

---

## Storage

| Mount | Host Path | Purpose |
|-------|-----------|---------|
| `/data` | `/mnt/storage/minecraft` | World, mods, config, logs |

`restart: "no"` — server does NOT auto-start on Docker daemon boot. Must run `./start.sh`.

---

## Playit Tunnel

External access via Playit.gg tunnel.

| Setting | Value |
|---------|-------|
| Public address | `sales-arguments.gl.joinmc.link` |
| Tunnel type | Minecraft Java |
| Local IP | 192.168.0.250 |
| Local port | 25565/30065 |
| Proxy | None |

Playit runs as a systemd service but is **disabled** at boot — controlled by `start.sh` / `stop.sh`.

---

## Status Monitor

A companion container (`mc-status`) runs a Python HTTP server on port 8082:

- **Image:** `python:3-alpine`
- **Endpoint:** `/` returns JSON with server online/offline status, version, player count
- **Script:** `/mnt/storage/mc_status_server.py`
- **Used by:** Glance dashboard for the Minecraft status widget

---

## Scripts

Located in `apps/minecraft-docker/`:

| Script | Action |
|--------|--------|
| `start.sh` | Start Minecraft + Playit |
| `stop.sh` | Graceful stop Minecraft + Playit |
| `restart.sh` | Restart both |
| `status.sh` | Show container state + logs |
| `logs.sh` | Tail logs |
| `console.sh` | Attach to server console |
| `deploy.sh` | Pull latest image + deploy |

---

## Problems Faced

- **Java 25 breaks Mixin mods** → pinned to `java17` (now `java21` for 1.21.1)
- **hostPort not working on K3s** → switched to NodePort
- **Whitelist env var confusion** → `WHITELIST=false` treated as player name "false", fixed by not setting `WHITELIST` when disabled
- **Docker permission denied** → user needs `sg docker -c` or relogin for group membership
- **Playit tunnel "broken pipe"** → tunnel was pointing to `127.0.0.1` instead of node IP `192.168.0.250`
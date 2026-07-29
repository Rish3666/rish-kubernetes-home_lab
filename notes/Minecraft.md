# Minecraft Server

**Approach:** Docker Compose (not K3s)  
**Container:** `itzg/minecraft-server:java21`  
**Mod loader:** Fabric  
**Version:** 1.21.11  
**Status:** Stopped (start with `./start.sh`)

> See also: [[Scripts]], [[Networking#Minecraft Access]], [[Bootstrap#Minecraft]], [[Troubleshooting#Minecraft]]

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
MEMORY: "6G"
MODE: survival
DIFFICULTY: normal
ONLINE_MODE: "FALSE"
VIEW_DISTANCE: 24
SIMULATION_DISTANCE: 16
```

---

## Storage

| Mount | Host Path |
|-------|-----------|
| `/data` | `/mnt/storage/minecraft` |

`restart: "no"` — server does NOT auto-start on boot. Must run `./start.sh`.

---

## Playit Tunnel

| Setting | Value |
|---------|-------|
| Public address | `sales-arguments.gl.joinmc.link` |
| Tunnel type | Minecraft Java |
| Local IP | `192.168.0.250` |
| Local port | `25565` |

[[Scripts#start.sh]] controls Playit automatically.

---

## Status Monitor

A companion container (`mc-status`) runs a Python HTTP server on port 8082, used by [[Glance]] for the Minecraft status widget.

---

## Scripts

Located in `apps/minecraft-docker/`:

| Script | Action |
|--------|--------|
| `start.sh` | Start Minecraft + Playit |
| `stop.sh` | Graceful stop both |
| `restart.sh` | Restart both |
| `status.sh` | Show state + logs |
| `logs.sh` | Tail logs |
| `console.sh` | Attach to console |

All details: [[Scripts#Minecraft Scripts]]

---

## Known Issues

See [[Troubleshooting#Minecraft]] for:
- Java 25 Mixin crashes
- Playit "broken pipe"
- Whitelist env var confusion
- Docker permission denied
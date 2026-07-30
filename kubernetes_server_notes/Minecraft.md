# Minecraft Server

> Fabric 1.21.11 server running in Docker with Playit tunnel for external access.
> Not on K3s — runs via Docker Compose.

---

## Overview

A Fabric-modded Minecraft server using `itzg/minecraft-server:java21` Docker image. The server is NOT auto-started — must be manually started with `start.sh`. External access is provided through a Playit.gg tunnel.

**Container:** `itzg/minecraft-server:java21`
**Mod loader:** Fabric 0.18.4
**Version:** 1.21.11
**Status:** Stopped by default (start with `./start.sh`)

## Configuration

### Docker Compose (docker-compose.yml)

```yaml
services:
  minecraft:
    image: itzg/minecraft-server:java21
    container_name: minecraft
    restart: "no"              # Manual start only
    ports:
      - "25565:25565"          # Game port
      - "30065:25565"          # Alternative port
    environment:
      EULA: "TRUE"
      TYPE: FABRIC
      VERSION: "1.21.11"
      FABRIC_LOADER_VERSION: "0.18.4"
      MEMORY: "6G"
      MODE: survival
      DIFFICULTY: normal
      MAX_PLAYERS: "10"
      VIEW_DISTANCE: "24"
      SIMULATION_DISTANCE: "16"
      MOTD: "rishlab - Fabric 1.21.11"
      ONLINE_MODE: "FALSE"     # Offline mode (no Microsoft auth)
      ENABLE_AUTOPAUSE: "FALSE"
      OVERRIDE_SERVER_PROPERTIES: "TRUE"
      REMOVE_OLD_MODS: "FALSE"
      TZ: Asia/Kolkata
    volumes:
      - /mnt/storage/minecraft:/data
```

### Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `TYPE` | FABRIC | Mod loader |
| `VERSION` | 1.21.11 | Minecraft version |
| `FABRIC_LOADER_VERSION` | 0.18.4 | Fabric loader |
| `MEMORY` | 6G | RAM allocation (of 8GB total) |
| `ONLINE_MODE` | FALSE | Offline mode (no premium auth required) |
| `MODE` | survival | Game mode |
| `DIFFICULTY` | normal | Difficulty level |
| `VIEW_DISTANCE` | 24 | Chunk view distance |

> **Important:** Use `itzg/minecraft-server:java21` tag. Java 25+ breaks Fabric mixins.

## Storage

| Mount | Host Path |
|-------|-----------|
| `/data` | `/mnt/storage/minecraft` |

Contains world data, mods, config, and server properties.

## Status Monitor

A companion container (`mc-status`) runs a Python HTTP server on port 8082. Used by [[Glance]] for the Minecraft status widget.

## Playit Tunnel

| Setting | Value |
|---------|-------|
| Public address | `sales-arguments.gl.joinmc.link` |
| Tunnel type | Minecraft Java |
| Local IP | `192.168.0.112` |
| Local port | 25565 |

The Playit agent runs as a systemd service (`playit.service`), controlled by the start/stop scripts.

## Access

| Method | Address | Port |
|--------|---------|------|
| Playit tunnel (external) | `sales-arguments.gl.joinmc.link` | 25565 |
| LAN | `192.168.0.112` | 25565 |

## Installation Guide

### Prerequisites

- Docker installed (see [[Bootstrap#Docker]])
- Playit account (free at playit.gg)
- Music files don't need to exist for Minecraft to work

### Step 1: Set Up Storage

```bash
sudo mkdir -p /mnt/storage/minecraft
```

### Step 2: Create Docker Compose

The bootstrap script creates the compose file, or create `apps/minecraft-docker/docker-compose.yml` manually with the config above.

### Step 3: Install Playit

```bash
# Download and install
sudo mkdir -p /opt/playit /etc/playit /var/log/playit
curl -fsSL https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64.tar.gz -o /tmp/playit.tar.gz
tar xzf /tmp/playit.tar.gz -C /tmp/
sudo install -m 755 /tmp/playit-linux-amd64 /opt/playit/playitd

# Create config
sudo tee /etc/playit/playit.toml << 'EOF'
secret_key = "YOUR_SECRET_KEY_HERE"
EOF

# Create systemd service
sudo tee /usr/lib/systemd/system/playit.service << 'UNIT'
[Unit]
Description=Playit Agent
After=network-pre.target

[Service]
User=playit
ExecStart=/opt/playit/playitd --secret-path /etc/playit/playit.toml --socket-path /run/playit/playitd.sock -l /var/log/playit/playit.log
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

# Create user
sudo useradd -r -s /sbin/nologin playit
sudo chown -R playit:playit /opt/playit /etc/playit /var/log/playit
sudo systemctl daemon-reload
```

### Step 4: Configure Tunnel

```bash
cd apps/minecraft-docker
./playit-start.sh
```

This starts the Playit agent in interactive mode. Follow the URL to claim the agent, then create a tunnel:

```
Type: Minecraft Java
Local host: 192.168.0.112
Local port: 25565
```

Stop the interactive mode (Ctrl+C) after configuring. The tunnel will be managed by the systemd service.

### Step 5: Start the Server

```bash
cd apps/minecraft-docker
./start.sh
```

This starts:
1. The Minecraft container
2. The Playit systemd service

### Step 6: First-Gen World

On first start, the server generates the world. This takes 30-60 seconds on a J5005. Watch progress:

```bash
./logs.sh
```

## Scripts

| Script | Action |
|--------|--------|
| `start.sh` | Start Minecraft + Playit |
| `stop.sh` | Graceful stop via rcon + Playit |
| `restart.sh` | Stop both, start both |
| `status.sh` | Show container state + stats |
| `logs.sh` | Tail server logs |
| `console.sh` | Attach to server console |
| `deploy.sh` | Pull latest image, recreate container |

All scripts are in `apps/minecraft-docker/`.

## Known Issues

### Java 25 Mixin Crashes
Fabric mods use mixins that break with Java 25. Use the `java21` tag:
```yaml
image: itzg/minecraft-server:java21
```

### Playit "Broken Pipe"
The tunnel local address must be `192.168.0.112`, not `127.0.0.1`.

### Whitelist Auto-Enabling
If you set `WHITELIST` env var, it auto-enables whitelist mode. Remove the var if not needed.

### JSON/Gibberish on Join
Normal. The registry/biome sync message looks like garbled JSON. Wait 2-3 minutes.

# Scripts & Automation

## Minecraft Scripts

Located in `apps/minecraft-docker/`:

### `start.sh`
- Starts Minecraft container (or deploys if no container exists)
- Starts Playit tunnel via `sudo systemctl start playit`
- Displays connection info

### `stop.sh`
- Sends `/stop` via rcon-cli for graceful shutdown
- Waits up to 30s for container to exit
- Stops Playit tunnel via `sudo systemctl stop playit`

### `restart.sh`
- Stops Minecraft (graceful) + Playit
- Starts Minecraft + Playit

### `status.sh`
- Shows `docker compose ps`
- Shows `docker stats` (CPU, MEM, NET, DISK) if running
- Tails last 60 log lines

### `logs.sh`
- Default: last 50 lines
- `-f`: follow live

### `console.sh`
- Attaches to server console via `docker attach`

### `deploy.sh`
- Stops running server
- Pulls latest image
- Runs `compose up -d`

### `playit-start.sh`
- Standalone playit launcher (checks binary exists, exec's it)

---

## Systemd Services

### `playit.service`
**Path:** `/usr/lib/systemd/system/playit.service`  
**Status:** Disabled (does not auto-start on boot)  
**Controlled by:** `start.sh` / `stop.sh` scripts

```
[Unit]
Description=Playit Agent
Wants=network-pre.target
After=network-pre.target

[Service]
User=playit
Group=playit
ExecStart=/opt/playit/playitd --secret-path /etc/playit/playit.toml --socket-path /run/playit/playitd.sock -l /var/log/playit/playit.log
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### `screenoff.service`
**Path:** `/etc/systemd/system/screenoff.service`  
**Status:** Disabled  
Turns off console display via `setterm`. Needed `Environment=TERM=linux` fix.

```
[Service]
Type=oneshot
Environment=TERM=linux
ExecStart=/usr/bin/setterm --blank force --powersave powerdown --powerdown 1
```

### `panel-off.service` + `panel-off.timer`
**Path:** `/etc/systemd/system/panel-off.service`  
Turns off display backlight via sysfs:
```
echo 4 > /sys/class/graphics/fb0/blank
echo 4 > /sys/class/backlight/intel_backlight/bl_power
```
Timer triggers 60s after boot. Note: may not work on all hardware.

---

## Systemd Scripts in Repo

Located in `scripts/`:

| File | Purpose |
|------|---------|
| `playit.service` | Alternative playit service (runs as rishlab user) |
| `panel-off.service` | Display power-off service |
| `panel-off.timer` | Timer for panel-off |
| `k3s.service` | K3s systemd unit |
# Scripts & Automation

> See also: [[Bootstrap]], [[Minecraft#Scripts]], [[Troubleshooting]]

---

## Minecraft Scripts

Located in `apps/minecraft-docker/`. All scripts also control the [[Minecraft#Playit Tunnel]] Playit tunnel via `sudo systemctl`.

### `start.sh`
Starts Minecraft container + Playit tunnel. Shows connection info.

### `stop.sh`
Graceful shutdown via rcon-cli, then stops Playit.

### `restart.sh`
Stops both, starts both.

### `status.sh`
Shows `docker compose ps`, `docker stats`, last 60 log lines.

### `logs.sh`
Tail logs (`-f` for live follow).

### `console.sh`
Attach to server console via `docker attach`.

### `deploy.sh`
Pull latest image, recreate container.

---

## Systemd Services

### playit.service
**Status:** Disabled at boot (controlled by start/stop scripts)

Service runs as `playit` user, auto-restarts on failure. See [[Minecraft#Playit Tunnel]].

### screenoff.service
**Status:** Disabled  
Turns off console display. Had to set `Environment=TERM=linux` to fix boot failure.

### panel-off.service + panel-off.timer
Turns off display backlight via sysfs. Timer triggers 60s after boot.

---

## Repo Scripts

Located in `scripts/`:

| File | Purpose |
|------|---------|
| `playit.service` | Alternative playit service unit |
| `panel-off.service` | Display power-off service |
| `panel-off.timer` | Timer for panel-off |
| `k3s.service` | K3s systemd unit |
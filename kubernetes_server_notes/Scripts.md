# Scripts & Automation

> See also: [[Bootstrap]], [[Minecraft#Scripts]], [[Troubleshooting]]

---

## Minecraft Scripts

Located in `apps/minecraft-docker/`. All scripts control the server and Playit tunnel together.

| Script | Action |
|--------|--------|
| `start.sh` | Start Minecraft container + Playit tunnel. Shows connection info. |
| `stop.sh` | Graceful shutdown via rcon-cli, then stops Playit. |
| `restart.sh` | Stop both, start both. |
| `status.sh` | Show `docker compose ps`, `docker stats`, last 60 log lines. |
| `logs.sh` | Tail logs (`-f` for live follow). |
| `console.sh` | Attach to server console via `docker attach`. |
| `deploy.sh` | Pull latest image, recreate container. |
| `playit-start.sh` | Start Playit agent only for initial tunnel setup. |

## Systemd Services

### rishlab-hosts.service
Updates `/etc/hosts` with K3s ClusterIPs so Tailscale Serve can route to services. Runs on boot after K3s starts.

**Unit:** `/etc/systemd/system/rishlab-hosts.service`
**Script:** `/usr/local/bin/update-rishlab-hosts`

The script queries `kubectl get svc -A` and writes entries like:
```
10.43.176.98  glance.kube
10.43.110.134  navidrome.kube
10.43.170.52  nextcloud.kube
```

### playit.service
**Status:** Disabled at boot (controlled by Minecraft start/stop scripts).

Runs as `playit` user. Auto-restarts on failure.
Service file: `/usr/lib/systemd/system/playit.service`

### screenoff.service
**Status:** Disabled (enable manually).  
Turns off console display via `setterm`. Had to set `Environment=TERM=linux` to fix boot failure on Debian 13.

### panel-off.service
**Status:** Enabled.  
Turns off display backlight via sysfs at `/sys/class/graphics/fb0/blank` and `/sys/class/backlight/intel_backlight/bl_power`.

### panel-off.timer
**Status:** Enabled.  
Triggers `panel-off.service` 60 seconds after boot.

### Display Control

Manual control:
```bash
# Turn display back on
/home/rish/panel-on.sh
```

Contents of `panel-on.sh`:
```bash
#!/bin/bash
echo 0 > /sys/class/graphics/fb0/blank
echo 0 > /sys/class/backlight/intel_backlight/bl_power
```

## Repo Scripts

Located in `scripts/`:

| File | Purpose |
|------|---------|
| `playit.service` | Alternative playit service unit (fallback) |
| `panel-off.service` | Display power-off service unit |
| `panel-off.timer` | Timer unit for panel-off |
| `k3s.service` | K3s systemd unit |

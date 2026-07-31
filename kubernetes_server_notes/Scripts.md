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

### panel-off.service
**Status:** Enabled.
**Purpose:** Powers off the display backlight via sysfs at `/sys/class/graphics/fb0/blank` and `/sys/class/backlight/intel_backlight/bl_power`.

**Why `After=multi-user.target` + `ExecStartPre=/bin/sleep 10`:** The sysfs paths don't exist until the GPU driver initializes ~10s after boot. The `sleep 10` gives the driver time; `|| true` makes the service fail gracefully if paths still don't exist. Without this, the service fails with `Directory nonexistent` on some boots.

**Why no `screenoff.service`:** The old `setterm`-based service printed `Inappropriate ioctl for device` on every boot — `setterm` needs a console TTY that systemd oneshot services don't provide. It was redundant with `panel-off` and has been removed.

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
| `panel-on.sh` | Restore display backlight (undoes panel-off) |
| `k3s.service` | K3s systemd unit |
| `rishlab-hosts.service` | /etc/hosts updater unit |
| `update-rishlab-hosts` | Script that syncs ClusterIPs into /etc/hosts |

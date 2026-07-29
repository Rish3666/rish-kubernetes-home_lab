# Troubleshooting

> See also: [[Bootstrap#Debugging]], [[Minecraft#Known Issues]], [[Scripts]]

---

## Minecraft

### "No route to host" (local LAN)
**Fix:** Connect to `192.168.0.250:25565`. Verify with `nc -zv 192.168.0.250 25565`.

### Playit "broken pipe"
**Fix:** Tunnel must point to `192.168.0.250:25565`, not `127.0.0.1`.

### Docker permission denied
**Fix:** `newgrp docker` or log out and back in. See [[Bootstrap#Docker]].

### JSON/gibberish in client
**Normal:** Minecraft's registry/biome sync. Wait 2-3 minutes.

### Whitelist auto-enabling
**Fix:** Don't set `WHITELIST` env var when disabled. See [[Minecraft]].

---

## Kubernetes

### Pod stuck in Pending
**Check:** `kubectl describe pod -n <ns> <pod>` for resource constraints.

### Pod in CrashLoopBackOff
**Check:** `kubectl logs -n <ns> <pod> --previous`

### NodePort not working
**Check:** `sudo ss -tlnp | grep <port>`. K3s embedded proxy may not bind host ports.

### PV stuck in Released
**Fix:** `kubectl delete pv <pv-name>`

---

## System

### screenoff.service fails at boot
**Fix:** Add `Environment=TERM=linux` to service unit.

### Display stays on
**Fix:** `panel-off.service` uses sysfs. May not work on all hardware.

---

## Tailscale

### Can't reach *.ts.net:port
**Fix:** `tailscale serve --bg --https <port> http://<svc-ip>:<port>`
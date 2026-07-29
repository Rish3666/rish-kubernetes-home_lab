# Troubleshooting

## Minecraft

### "Failed to connect / No route to host" (local LAN)
**Cause:** Firewall or wrong address.  
**Fix:** Connect to `192.168.0.250:25565` or `192.168.0.250:30065`. Verify with `nc -zv 192.168.0.250 30065`.

### "Outdated client" error
**Cause:** Version mismatch between client and server.  
**Fix:** Ensure client is Minecraft 1.21.1 with Fabric loader.

### "Connection refused" on localhost
**Cause:** K3s NodePort doesn't bind `127.0.0.1` by default.  
**Fix:** Use the node IP (`192.168.0.250`) instead of localhost.

### Playit tunnel "broken pipe"
**Cause:** Tunnel pointing to `127.0.0.1:30065` instead of `192.168.0.250:30065`.  
**Fix:** Update tunnel in Playit.gg dashboard to `192.168.0.250:30065`.

### Playit tunnel "timeout connecting to claim address"
**Cause:** Agent couldn't reach the Minecraft pod.  
**Fix:** Ensure Minecraft container is running before connecting.

### Docker permission denied
**Cause:** User not in `docker` group in current shell session.  
**Fix:** `newgrp docker` or log out and back in.

### JSON/gibberish in console when connecting
**Cause:** Minecraft's registry/biome sync — normal for 1.20.1/1.21.1.  
**Fix:** Wait 2-3 minutes for it to complete.

### White-list automatically enabling
**Cause:** `WHITELIST=false` env var treated as a player name "false".  
**Fix:** Don't set `WHITELIST` when disabled; or use `ENABLE_WHITELIST=true` + `WHITELIST=player1,player2`.

### Modpack download failure on startup
**Cause:** Modrinth API timeout or invalid slug.  
**Fix:** Check `TYPE=MODRINTH`, `MODRINTH_PROJECT` slug is correct, and DNS (8.8.8.8) is reachable.

---

## Kubernetes

### Pod stuck in Pending
**Cause:** Insufficient CPU/memory resources on node.  
**Check:** `kubectl describe pod -n <ns> <pod>` for scheduling errors.

### Pod in CrashLoopBackOff
**Cause:** Application crashes on startup.  
**Check:** `kubectl logs -n <ns> <pod> --previous`

### NodePort not working
**Cause:** K3s embedded proxy may not bind host ports.  
**Check:** `sudo ss -tlnp | grep <port>`. If not listening, use `hostNetwork: true` or switch to LoadBalancer.

### PV stuck in Released
**Cause:** PVC was deleted but PV has `Retain` policy.  
**Fix:** Delete PV manually: `kubectl delete pv <pv-name>`

---

## System

### screenoff.service fails at boot
**Error:** `$TERM is not defined`  
**Fix:** Add `Environment=TERM=linux` to the service unit:
```ini
[Service]
Environment=TERM=linux
```

### "No route to host" for external connections
**Cause:** Router not forwarding ports, or client isolation enabled.  
**Fix:** Port forward on router, or use Tailscale/Playit tunnel.

### Display stays on after boot
**Cause:** `screenoff.service` runs but hardware doesn't support `setterm` blanking.  
**Fix:** Use `panel-off.service` (sysfs method) or just disable both and let hardware sleep.

---

## Tailscale

### Can't reach service at *.ts.net:port
**Cause:** Tailscale Serve not configured for that port.  
**Fix:** `tailscale serve --bg --https <port> http://<service-ip>:<port>`

### Tailscale SSH not working
**Cause:** Not enabled in Tailscale admin console or `tailscale up --ssh` not run.  
**Fix:** `sudo tailscale up --ssh`
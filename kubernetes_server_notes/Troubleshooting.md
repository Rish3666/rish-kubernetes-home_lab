# Troubleshooting

> See also: [[Bootstrap#Debugging]], [[Minecraft#Known Issues]], [[Scripts]]

---

## Kubernetes

### Pod stuck in Pending
- `kubectl describe pod -n <ns> <pod>` — look for resource constraints or PVC issues
- Check PV status: `kubectl get pv`
- Check PVC status: `kubectl get pvc -n <ns>`

### Pod in CrashLoopBackOff
```bash
kubectl logs -n <ns> <pod> --previous
kubectl describe pod -n <ns> <pod>
```

### NodePort not working
```bash
sudo ss -tlnp | grep <port>
```
K3s embedded proxy may not bind host ports for some service types.

### PV stuck in Released
```bash
kubectl delete pv <pv-name>
```
Then re-create the PV if needed.

### MariaDB/Redis won't start
- Check storage: `kubectl get pvc -n databases`
- If PVC is Pending, the `local-path` storage class may not have provisioned yet
- Check node resources: `kubectl describe node`

## System

### /var filling up
K3s data should be symlinked to the HDD:
```bash
ls -la /var/lib/rancher
# Should point to: /mnt/storage/k3s/rancher
```

### panel-off.service fails at boot
The sysfs paths don't exist until the GPU driver loads (~10s after boot). The service has `ExecStartPre=/bin/sleep 10` and `|| true` guards, so it should always succeed. If it still fails:
- Check paths exist: `ls /sys/class/graphics/fb0/blank /sys/class/backlight/intel_backlight/bl_power`
- Increase the sleep in `ExecStartPre`

### Display stays on
- `panel-off.service` uses sysfs. May not work on all hardware.
- Try manually: `echo 4 | sudo tee /sys/class/graphics/fb0/blank`
- To restore: `/home/rish/panel-on.sh`

### Docker permission denied
```bash
newgrp docker
# Or log out and back in
```
See [[Bootstrap#Docker]].

## Tailscale

### Can't reach *.ts.net:port
- Verify Tailscale is connected: `tailscale status`
- Verify Serve config: `tailscale serve status`
- Add/re-add proxy: `tailscale serve --bg --https <port> http://<svc-ip>:<port>`
- If backend uses a hostname, make sure it resolves (check `/etc/hosts`)

### Tailscale Serve backends failing
- ClusterIPs change on pod restart. Run `sudo systemctl restart rishlab-hosts` to update `/etc/hosts`
- Verify entries: `grep .kube /etc/hosts`
- After updating, re-apply Tailscale Serve: `tailscale serve --bg --https <port> http://<hostname>:<port>`

## Minecraft

### "No route to host" (local LAN)
Connect to `192.168.0.112:25565`. Verify with:
```bash
nc -zv 192.168.0.112 25565
```

### Playit "broken pipe"
Tunnel must point to `192.168.0.112:25565`, not `127.0.0.1`.

### JSON/gibberish in client
Normal. Minecraft's registry/biome sync. Wait 2-3 minutes.

### Whitelist auto-enabling
Don't set `WHITELIST` env var when disabled.

### Java 25 Mixin crashes
Use Java 21 (`itzg/minecraft-server:java21`) for Fabric compatibility.

## Applications

### Nextcloud config.php permissions
Config map updates don't auto-reload Nextcloud. After changing configs in values:
```bash
kubectl rollout restart -n nextcloud deployment/nextcloud
```

### Nextcloud initial setup fails
The `occ maintenance:install` may fail if the database isn't ready or if configs have issues:
```bash
kubectl exec -n nextcloud deployment/nextcloud -- occ maintenance:install \
  --database mysql \
  --database-host mariadb.databases.svc.cluster.local \
  --database-name nextcloud \
  --database-user nextcloud \
  --database-pass <password> \
  --admin-user admin \
  --admin-pass <admin-password>
```

### Glance blank page
- Check Glance logs for YAML parse errors: `kubectl logs -n glance deployment/glance`
- Verify ConfigMap: `kubectl get cm -n glance glance-config -o yaml`
- Verify config mounted: `kubectl exec -n glance deployment/glance -- cat /app/config/glance.yml`

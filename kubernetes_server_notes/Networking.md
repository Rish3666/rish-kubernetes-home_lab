# Networking

> See also: [[Architecture]], [[Kubernetes#Services]], [[Bootstrap#Networking]]

---

## Network Stack

```
Internet ──→ Router (192.168.0.1)
                │
                ├── K3s Host (192.168.0.250)
                │     ├── Traefik LoadBalancer (80:30205, 443:32184)
                │     ├── Docker (Minecraft: 25565, 30065)
                │     ├── mc-status (8082)
                │     └── Tailscale (100.x.x.x)
                │
                └── Other LAN devices
```

---

## Tailscale

**Hostname:** `rishlab.tailb96c63.ts.net`  
**MagicDNS:** Enabled

### Tailscale Serve

| Port | Service | Backend |
|------|---------|---------|
| 4443 | [[Glance]] | `http://glance.glance:8080` |
| 4533 | [[Navidrome]] | `http://navidrome.navidrome:4533` |
| 8443 | [[Nextcloud]] | `http://nextcloud.nextcloud:8080` |

SSH enabled via Tailscale SSH.

---

## Traefik (Ingress Controller)

- Default K3s ingress controller
- **Type:** LoadBalancer on `192.168.0.250`
- **Ports:** `80:30205`, `443:32184`

| Host | Service | Port |
|------|---------|------|
| `glance.lab.local` | glance | 8080 |
| `navidrome.lab.local` | navidrome | 4533 |
| `rishlab.tailb96c63.ts.net` | nextcloud | 8080 |

---

## Minecraft Access

| Method | Address | Port |
|--------|---------|------|
| Local LAN | `192.168.0.250` | 25565 or 30065 |
| Playit tunnel | `sales-arguments.gl.joinmc.link` | 25565 |

---

## Port Map

| Port | Service | Type |
|------|---------|------|
| 22 | SSH | System |
| 53 | CoreDNS | ClusterIP |
| 80/443 | Traefik | LoadBalancer |
| 8080 | Nextcloud / Glance | ClusterIP |
| 31433 | Navidrome | NodePort |
| 8443 | Nextcloud (TS) | Tailscale Serve |
| 4443 | Glance (TS) | Tailscale Serve |
| 4533 | Navidrome (TS) | Tailscale Serve |
| 25565 | Minecraft | Docker host |
| 30065 | Minecraft alt | Docker host |
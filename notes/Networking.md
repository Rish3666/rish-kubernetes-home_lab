# Networking

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
                └── Other LAN devices (WiFi/Ethernet)
```

---

## Tailscale

- **Hostname:** `rishlab.tailb96c63.ts.net`
- **Services exposed via Tailscale Serve:**

| Port | Service | Backend |
|------|---------|---------|
| 4443 | Glance | `http://glance.glance:8080` |
| 4533 | Navidrome | `http://navidrome.navidrome:4533` |
| 8443 | Nextcloud | `http://nextcloud.nextcloud:8080` |

- **SSH:** Tailscale SSH enabled
- **MagicDNS:** Enabled

---

## Traefik (Ingress Controller)

- Default K3s ingress controller
- **Type:** LoadBalancer
- **External IP:** `192.168.0.250`
- **Ports:** `80:30205/TCP`, `443:32184/TCP`

### Ingress Rules
| Host | Service | Port |
|------|---------|------|
| `glance.lab.local` | glance | 8080 |
| `navidrome.lab.local` | navidrome | 4533 |
| `rishlab.tailb96c63.ts.net` | nextcloud | 8080 |

---

## DNS

### Local (`/etc/hosts`)
```
192.168.0.250 glance.lab.local navidrome.lab.local nextcloud.lab.local
```

### External
- Tailscale MagicDNS for `.ts.net` domain
- Playit.gg DNS for Minecraft (`sales-arguments.gl.joinmc.link`)

---

## Minecraft Access

| Method | Address | Port |
|--------|---------|------|
| Local LAN | `192.168.0.250` | 25565 or 30065 |
| Playit tunnel | `sales-arguments.gl.joinmc.link` | 25565 |

---

## Firewall

No `ufw` or `iptables` rules blocking traffic. K3s NodePorts are accessible on all interfaces.

---

## Port Map

| Port | Service | Type |
|------|---------|------|
| 22 | SSH | System |
| 53 | CoreDNS | K3s ClusterIP |
| 80 | Traefik HTTP | LoadBalancer → 30205 |
| 443 | Traefik HTTPS | LoadBalancer → 32184 |
| 8080 | Nextcloud / Glance | ClusterIP |
| 31433 | Navidrome | NodePort |
| 8443 | Nextcloud (Tailscale) | Tailscale Serve |
| 4443 | Glance (Tailscale) | Tailscale Serve |
| 4533 | Navidrome (Tailscale + NodePort) | Tailscale Serve / NodePort |
| 8082 | Minecraft status | Docker host |
| 25565 | Minecraft game | Docker host |
| 30065 | Minecraft game (alt) | Docker host |
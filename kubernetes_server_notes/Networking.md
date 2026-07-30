# Networking

> See also: [[Architecture]], [[Kubernetes#Services]], [[Bootstrap#Networking]]

---

## Network Stack

```
Internet ──→ Router (192.168.0.1)
                │
                ├── Tailscale VPN (100.110.144.56)
                │     └── deb-rish.tailb96c63.ts.net
                │           ├── :4443 → Glance
                │           ├── :4533 → Navidrome
                │           └── :8443 → Nextcloud
                │
                ├── LAN (192.168.0.112)
                │     ├── Traefik LoadBalancer (80:30205, 443:32184)
                │     ├── Docker (Minecraft: 25565)
                │     ├── mc-status status API (8082)
                │     └── SSH (22)
                │
                └── Playit Tunnel
                      └── sales-arguments.gl.joinmc.link:25565 → Minecraft
```

## Tailscale

| Setting | Value |
|---------|-------|
| Hostname | `deb-rish` |
| Tailnet | `tailb96c63.ts.net` |
| MagicDNS | Enabled |
| Tailscale IP | `100.110.144.56` |
| SSH | Enabled (Tailscale SSH) |

### Tailscale Serve

Tailscale Serve proxies HTTPS from Tailscale's MagicDNS to internal ClusterIPs. Tailscale handles TLS termination.

| Port | Service | Backend URL |
|------|---------|-------------|
| 4443 | [[Glance]] | `http://glance.glance:8080` |
| 4533 | [[Navidrome]] | `http://navidrome.navidrome:4533` |
| 8443 | [[Nextcloud]] | `http://nextcloud.nextcloud:8080` |

Commands:
```bash
tailscale serve --bg --https 4443 http://glance.glance:8080
tailscale serve --bg --https 4533 http://navidrome.navidrome:4533
tailscale serve --bg --https 8443 http://nextcloud.nextcloud:8080
```

## /etc/hosts Entries

Tailscale Serve backends point to ClusterIPs that are not resolvable via DNS outside the cluster. The service `rishlab-hosts.service` runs `/usr/local/bin/update-rishlab-hosts` to keep `/etc/hosts` entries current:

```
# Added by rishlab-hosts service
10.43.176.98  glance.kube
10.43.110.134  navidrome.kube
10.43.170.52  nextcloud.kube
```

These entries are used by Tailscale Serve backends (e.g., `http://nextcloud.kube:8080`).

## Traefik (Ingress Controller)

Default K3s ingress controller. Runs as a LoadBalancer service.

| Setting | Value |
|---------|-------|
| Type | LoadBalancer |
| LAN IP | `192.168.0.112` |
| HTTP Port | `80:30205` |
| HTTPS Port | `443:32184` |

### Ingress Rules

| Host | Service | Port |
|------|---------|------|
| `glance.lab.local` | glance | 8080 |
| `navidrome.lab.local` | navidrome | 4533 |
| `deb-rish.tailb96c63.ts.net` | nextcloud | 8080 |

## Port Map

| Port | Service | Type |
|------|---------|------|
| 22 | SSH | System |
| 53 | CoreDNS | ClusterIP (K3s) |
| 80:30205 | Traefik HTTP | LoadBalancer |
| 443:32184 | Traefik HTTPS | LoadBalancer |
| 8080 | Nextcloud / Glance | ClusterIP |
| 31433 | Navidrome | NodePort |
| 8082 | mc-status | Docker host |
| 4443 | Glance (TS) | Tailscale Serve |
| 4533 | Navidrome (TS) | Tailscale Serve |
| 8443 | Nextcloud (TS) | Tailscale Serve |
| 25565 | Minecraft game | Docker host |

## Minecraft Access

| Method | Address | Port |
|--------|---------|------|
| Local LAN | `192.168.0.112` | 25565 |
| Playit tunnel | `sales-arguments.gl.joinmc.link` | 25565 |

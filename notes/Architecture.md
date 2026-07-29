# Architecture

## High-Level Layout

```
┌─────────────────────────────────────────────────────┐
│                   HP All-in-One                      │
│               (Pentium J5005, 8GB)                    │
│                                                       │
│  ┌─────────────────────────────────────────────┐     │
│  │              K3s Cluster                     │     │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │     │
│  │  │ Nextcloud│  │ Navidrome│  │  Glance   │  │     │
│  │  │  (K3s)   │  │  (K3s)   │  │  (K3s)    │  │     │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  │     │
│  │       │              │              │        │     │
│  │  ┌────┴──────────────┴──────────────┴────┐  │     │
│  │  │       Traefik Ingress Controller       │  │     │
│  │  └────────────────┬──────────────────────┘  │     │
│  └───────────────────┼─────────────────────────┘     │
│                      │                                │
│  ┌───────────────────┼─────────────────────────┐     │
│  │          Tailscale VPN (MagicDNS)            │     │
│  │  glance.lab.local  navidrome.lab.local       │     │
│  │  rishlab.tailb96c63.ts.net:4443/4533/8443    │     │
│  └─────────────────────────────────────────────┘     │
│                                                       │
│  ┌─────────────────────────────────────────────┐     │
│  │     Minecraft (Docker Compose, not K3s)       │     │
│  │     Port 25565 + Playit tunnel                │     │
│  └─────────────────────────────────────────────┘     │
│                                                       │
│  ┌─────────────────────────────────────────────┐     │
│  │        Databases Namespace                   │     │
│  │  ┌──────────┐          ┌──────────┐         │     │
│  │  │  MariaDB │◄────────►│   Redis  │         │     │
│  │  │  (K3s)   │          │  (K3s)   │         │     │
│  │  └──────────┘          └──────────┘         │     │
│  └─────────────────────────────────────────────┘     │
│                                                       │
│  Storage: /dev/sdb (1TB HDD) → /mnt/storage          │
│    ├── music/       (Navidrome)                       │
│    ├── navidrome/   (Navidrome data)                  │
│    ├── nextcloud/   (Nextcloud files)                 │
│    └── minecraft/   (Minecraft world + mods)          │
└─────────────────────────────────────────────────────┘
```

## Deployment Methods

| Method | Services |
|--------|----------|
| **K3s + Helm** | Nextcloud, Navidrome, Glance, MariaDB, Redis |
| **Docker Compose** | Minecraft server |
| **Systemd** | Playit tunnel, panel-off (display) |

## Service Dependencies

```
Nextcloud ──┬── MariaDB (databases namespace)
            └── Redis (databases namespace)

Navidrome ──→ HostPath PV (music files)

Glance ──→ HTTP checks to all services for monitoring

Minecraft ──→ Playit.gg tunnel for external access
```

## Access Methods

| Service | Internal (Tailscale) | External |
|---------|---------------------|----------|
| Nextcloud | `rishlab.tailb96c63.ts.net:8443` | — |
| Navidrome | `rishlab.tailb96c63.ts.net:4533` | — |
| Glance | `rishlab.tailb96c63.ts.net:4443` | — |
| Minecraft | `192.168.0.250:25565/30065` | `sales-arguments.gl.joinmc.link` |
| SSH | `192.168.0.250:22` | Tailscale SSH |
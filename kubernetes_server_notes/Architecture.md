# Architecture

> See also: [[Kubernetes]], [[Networking]], [[Storage]]

---

## High-Level Layout

```
┌──────────────────────────────────────────────────────────┐
│                   HP All-in-One (deb-rish)                │
│               (Pentium J5005, 8GB)                        │
│                                                           │
│  ┌─────────────────────────────────────────────────┐     │
│  │              K3s Cluster (v1.36.2)               │     │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │     │
│  │  │ Nextcloud│  │ Navidrome│  │    Glance     │  │     │
│  │  │ (Helm)   │  │ (Helm)   │  │ (Local Chart) │  │     │
│  │  └────┬─────┘  └────┬─────┘  └──────┬───────┘  │     │
│  │       │              │               │          │     │
│  │  ┌────┴──────────────┴───────────────┴──────┐  │     │
│  │  │       Traefik Ingress Controller          │  │     │
│  │  └────────────────┬─────────────────────────┘  │     │
│  └───────────────────┼────────────────────────────┘     │
│                      │                                  │
│  ┌───────────────────┼─────────────────────────────┐    │
│  │          Tailscale VPN (MagicDNS)                │    │
│  │  deb-rish.tailb96c63.ts.net:4443/4533/8443       │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │     Minecraft (Docker Compose, not K3s)          │    │
│  │     Port 25565 + Playit tunnel                   │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │        Databases Namespace (shared)              │    │
│  │  ┌──────────┐          ┌──────────┐             │    │
│  │  │  MariaDB │◄────────►│   Redis  │             │    │
│  │  │ (Bitnami)│          │ (Bitnami)│             │    │
│  │  └──────────┘          └──────────┘             │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  Storage: /dev/sdb2 (1TB HDD) → /mnt/storage            │
│    ├── music/       (Navidrome library)                  │
│    ├── navidrome/   (Navidrome data/cache)               │
│    ├── nextcloud/   (Nextcloud user files)               │
│    ├── minecraft/   (Minecraft world + mods)             │
│    └── k3s/         (K3s data dir)                       │
└──────────────────────────────────────────────────────────┘
```

## Deployment Methods

| Method | Services |
|--------|----------|
| **K3s + Helm (Bitnami)** | [[Databases]] (MariaDB, Redis) |
| **K3s + Helm (Official)** | [[Nextcloud]] |
| **K3s + Helm (Local Chart)** | [[Navidrome]], [[Glance]] |
| **Docker Compose** | [[Minecraft]] |
| **Systemd** | [[Scripts#Playit]], [[Scripts#Display Services]] |

## Service Dependencies

```
Nextcloud ──┬── MariaDB (databases namespace)
            └── Redis (databases namespace)

Navidrome ──→ HostPath PV (music files at /mnt/storage/music)

Glance ──→ HTTP checks to all services for status monitoring
         └── /proc + /sys mount for host stats

Minecraft ──→ Playit.gg tunnel (external access via playit.gg)
            └── mc-status companion container (port 8082)
```

## Access Flow

```
Internet → Tailscale VPN → deb-rish.tailb96c63.ts.net
                              │
                    Tailscale Serve (port 4443, 4533, 8443)
                              │
                    Traefik Ingress ←→ Service ←→ Pod ←→ PV

Minecraft (external) → Playit tunnel → 192.168.0.112:25565
```

# RishLab Homelab

**Repurposed HP All-in-One (Pentium J5005, 8GB RAM) → 24/7 K3s cluster**

> Don't throw away old hardware. It still serves.

---

## Overview

A single-node [[Kubernetes]] cluster on repurposed e-waste. Hosts personal cloud services, music streaming, and a unified dashboard — all accessible globally via [[Networking#Tailscale]].

Power draw: ~15W idle, ~25-30W load (~$20-30/year)

---

## System

| Note | Description |
|------|-------------|
| [[Hardware]] | HP All-in-One specs, CPU, RAM, disks |
| [[Architecture]] | System layout, service map, data flow |
| [[Networking]] | Tailscale, Traefik, DNS, port map |
| [[Storage]] | Disk layout, PVs, PVCs, backups |
| [[Kubernetes]] | K3s cluster, namespaces, pods, services |

## Services

| Service | Page | Purpose |
|---------|------|---------|
| [[Databases]] | Shared MariaDB + Redis | Backend for all apps |
| [[Nextcloud]] | File sync, calendar, contacts | Personal cloud |
| [[Navidrome]] | Music streaming | Self-hosted Spotify |
| [[Glance]] | Dashboard | Unified monitoring hub |
| [[Minecraft]] | Fabric 1.21.1 Docker server | Gaming |

## Operations

| Note | Description |
|------|-------------|
| [[Bootstrap]] | Fresh install automation |
| [[Scripts]] | Automation scripts and systemd services |
| [[Troubleshooting]] | Problems faced and how they were fixed |
| [[Future-Plans]] | Next services to deploy |

---

## Quick Access

| Service | Tailscale URL | LAN |
|---------|---------------|-----|
| Glance | `https://deb-rish.tailb96c63.ts.net:4443` | `http://192.168.0.112:30205` |
| Navidrome | `https://deb-rish.tailb96c63.ts.net:4533` | `http://192.168.0.112:31433` |
| Nextcloud | `https://deb-rish.tailb96c63.ts.net:8443` | `http://192.168.0.112:32184` |
| Minecraft | `sales-arguments.gl.joinmc.link:25565` | `192.168.0.112:25565` |

---

## Repo

[github.com/Rish3666/rish-kubernetes-home_lab](https://github.com/Rish3666/rish-kubernetes-home_lab)

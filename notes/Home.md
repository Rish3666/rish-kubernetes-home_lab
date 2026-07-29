# RishLab Homelab

**Repurposed HP All-in-One (Pentium J5005, 8GB RAM) → 24/7 K3s cluster**

> Don't throw away old hardware. It still serves.

---

## Overview

A single-node K3s Kubernetes cluster running on repurposed e-waste. Hosts personal cloud services, music streaming, a Minecraft server, and a unified dashboard — all accessible via Tailscale VPN.

**Power draw:** ~15W idle, ~25-30W load (~$20-30/year)

---

## Quick Links

| Note | Description |
|------|-------------|
| [[Hardware]] | HP All-in-One specs, CPU, RAM, disks |
| [[Architecture]] | System layout, service map, data flow |
| [[Kubernetes]] | K3s cluster, namespaces, pods, services |
| [[Databases]] | MariaDB + Redis (shared by all apps) |
| [[Nextcloud]] | File sync, calendar, contacts |
| [[Navidrome]] | Music streaming server |
| [[Minecraft]] | Fabric 1.21.1 Docker server + Playit tunnel |
| [[Glance]] | Self-hosted dashboard |
| [[Networking]] | Tailscale, Traefik, DNS, ports |
| [[Storage]] | Disk layout, PVs, PVCs, backups |
| [[Scripts]] | Automation scripts and systemd services |
| [[Troubleshooting]] | Problems faced and how they were fixed |
| [[Future-Plans]] | Next services to deploy |

---

## Repo

[https://github.com/Rish3666/rish-kubernetes-home_lab](https://github.com/Rish3666/rish-kubernetes-home_lab)
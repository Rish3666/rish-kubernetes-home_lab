# RishLab Homelab

**Repurposed HP All-in-One (Pentium J5005, 8GB RAM) → 24/7 K3s cluster**

> Don't throw away old hardware. It still serves.

---

## Overview

A single-node [[Kubernetes]] cluster running on repurposed e-waste. Hosts personal cloud services, music streaming, a Minecraft server, and a unified dashboard — all accessible via [[Networking#Tailscale]].

**Power draw:** ~15W idle, ~25-30W load (~$20-30/year)

---

## Quick Start

New to the homelab? Start here:
- [[Bootstrap]] — One-command setup for a fresh distro install
- [[Scripts]] — How to control services day-to-day
- [[Troubleshooting]] — Fix common issues

---

## System

| Note | Description |
|------|-------------|
| [[Hardware]] | HP All-in-One specs, CPU, RAM, disks |
| [[Architecture]] | System layout, service map, data flow |
| [[Networking]] | Tailscale, Traefik, DNS, port map |
| [[Storage]] | Disk layout, PVs, PVCs, backups |

---

## Kubernetes & Databases

| Note | Description |
|------|-------------|
| [[Kubernetes]] | K3s cluster, namespaces, pods, services |
| [[Databases]] | MariaDB + Redis (shared by all apps) |

---

## Applications

| Note | Description |
|------|-------------|
| [[Nextcloud]] | File sync, calendar, contacts |
| [[Navidrome]] | Music streaming server |
| [[Glance]] | Self-hosted dashboard |
| [[Minecraft]] | Fabric 1.21.1 Docker server + Playit tunnel |

---

## Operations

| Note | Description |
|------|-------------|
| [[Bootstrap]] | Fresh install automation |
| [[Scripts]] | Automation scripts and systemd services |
| [[Troubleshooting]] | Problems faced and how they were fixed |
| [[Future-Plans]] | Next services to deploy |

---

## Repo

[https://github.com/Rish3666/rish-kubernetes-home_lab](https://github.com/Rish3666/rish-kubernetes-home_lab)
# Glance Dashboard

> Self-hosted dashboard that aggregates all your feeds, services, and monitoring.
> Namespace: `glance`

---

## Overview

Glance is a lightweight, Go-based dashboard that displays RSS feeds, server stats, service health, YouTube channels, weather, stocks, and more — all in a single-page, fully customizable layout.

**Chart:** Local Helm chart (`charts/glance/`)
**Image:** `glanceapp/glance:v0.8.5`
**Status:** Running
**Type:** Stateless (no database)

## Configuration

### Application

| Setting | Value |
|---------|-------|
| Host | `glance.lab.local` |
| Port | 8080 |
| Service type | ClusterIP |
| Timezone | Asia/Kolkata (set via env) |

### Resources

| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 500m |
| Memory | 128Mi | 256Mi |

### Security

- Runs as non-root (UID 1000)
- Read-only root filesystem
- All Linux capabilities dropped
- Host `/proc` and `/sys` mounted for server-stats widget

## Dashboard Layout

### Left Column (Full Width)

| Widget | Source | Details |
|--------|--------|---------|
| Search | DuckDuckGo | With bangs for YouTube, GitHub, Reddit |
| Server Stats | Local host | CPU, RAM, disk via `/host/proc` + `/host/sys` |
| Service Monitor | HTTP checks | Navidrome, Nextcloud, Glance, Minecraft status |
| Hacker News | RSS | Top 10 stories, collapsed after 5 |
| YouTube | Channel RSS | LTT, Jeff Geerling, NetworkChuck |

### Right Column (Small)

| Widget | Source | Details |
|--------|--------|---------|
| Minecraft Status | `mc-status` API | Online/offline, player count, player list |
| GitHub Profile | GitHub API | Avatar, repos, followers |
| Recent Commits | GitHub API | Last 5 commits by `Rish3666` |

## Access

| Method | URL |
|--------|-----|
| Tailscale | `https://deb-rish.tailb96c63.ts.net:4443` |
| LAN (ingress) | `http://glance.lab.local` |

## Installation Guide

### Prerequisites

- K3s cluster running
- Helm installed
- Access to the repo's local charts

### Step 1: Create Namespace

```bash
kubectl create namespace glance
```

### Step 2: Deploy via Helm

```bash
helm upgrade --install glance charts/glance -n glance --wait --timeout 3m
```

### Step 3: Verify

```bash
kubectl get pods -n glance
# NAME                      READY   STATUS
# glance-78885dcf69-tb2r5   1/1     Running

kubectl get svc -n glance
# NAME      TYPE        CLUSTER-IP     PORT(S)
# glance    ClusterIP   10.43.176.98   8080/TCP
```

### Step 4: Check Dashboard

Browse to `https://deb-rish.tailb96c63.ts.net:4443` or port-forward for a quick check:

```bash
kubectl port-forward -n glance svc/glance 8080:8080
# Visit http://localhost:8080
```

## Configuration

The dashboard layout is defined in `charts/glance/values.yaml` under `glance.config`. Edit this YAML string to customize widgets.

To apply changes:

```bash
# Edit values.yaml, then upgrade
helm upgrade --install glance charts/glance -n glance --wait --timeout 3m

# ConfigMap updates don't auto-reload pods; restart after upgrade
kubectl rollout restart -n glance deployment/glance
```

Glance auto-reloads when the config file changes on disk inside the container, but the ConfigMap must be updated first (via Helm upgrade + rollout restart).

## Chart Details

The Glance chart is well-documented inline. Key template files:

| File | Purpose |
|------|---------|
| `templates/deployment.yaml` | Pod spec with security context, probes, host mounts |
| `templates/service.yaml` | ClusterIP service on port 8080 |
| `templates/ingress.yaml` | Traefik ingress (enabled by default) |
| `templates/configmap.yaml` | Injects glance.yml from values |
| `NOTES.txt` | Post-install instructions |

See `charts/glance/values.yaml` for full documentation of every configuration option.

## Troubleshooting

```bash
# Check logs for YAML parse errors
kubectl logs -n glance deployment/glance

# Verify config is mounted correctly
kubectl exec -n glance deployment/glance -- cat /app/config/glance.yml

# Check the rendered ConfigMap
kubectl get cm -n glance glance-config -o yaml
```

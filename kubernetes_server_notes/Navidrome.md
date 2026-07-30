# Navidrome

> Self-hosted music streaming server. The Spotify of your own music library.
> Namespace: `navidrome`

---

## Overview

Navidrome is a lightweight, open-source music server. It scans a music folder and provides a web UI + Subsonic API for streaming. Accessible via any Subsonic-compatible client (Ultrasonic, DSub, Tempo, etc.).

**Chart:** Local Helm chart (`apps/navidrome/`)
**Image:** `deluan/navidrome:latest`
**Version:** 0.61.1
**Status:** Running

## Configuration

### Application

| Setting | Value |
|---------|-------|
| Timezone | Asia/Kolkata |
| Music folder | `/music` (mounted from PV) |
| Data folder | `/data` (mounted from PV) |
| Image cache size | 500MB |
| Download rate limit | 0 (unlimited) |

### Service

| Setting | Value |
|---------|-------|
| Type | NodePort |
| Port | 4533 |
| NodePort | 31433 |

> NodePort is used for direct LAN access (faster for large uploads). Switch to ClusterIP if you only use Tailscale.

### Ingress

| Setting | Value |
|---------|-------|
| Host | `navidrome.lab.local` |
| Class | traefik |

### Storage

| Volume | Size | Host Path | Purpose |
|--------|------|-----------|---------|
| `navidrome-music-pv` | 100Gi | `/mnt/storage/music` | Music files (FLAC, MP3, etc.) |
| `navidrome-data-pv` | 5Gi | `/mnt/storage/navidrome` | Database, cache, config |

## Access

| Method | URL |
|--------|-----|
| Tailscale | `https://deb-rish.tailb96c63.ts.net:4533` |
| LAN (ingress) | `http://navidrome.lab.local` |
| LAN (direct) | `http://192.168.0.112:31433` |

## Installation Guide

### Prerequisites

- K3s cluster running
- Music files already on the HDD at `/mnt/storage/music`
- Helm installed

### Step 1: Create Namespace

```bash
kubectl create namespace navidrome
```

### Step 2: Create Persistent Volumes

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: navidrome-music-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/storage/music
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: navidrome-data-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/storage/navidrome
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: navidrome-music-pvc
  namespace: navidrome
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: manual
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: navidrome-data-pvc
  namespace: navidrome
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
EOF
```

### Step 3: Deploy via Helm

```bash
helm upgrade --install navidrome apps/navidrome -n navidrome --wait --timeout 3m
```

### Step 4: Create Initial Admin User

Navidrome creates the first user on its first visit. After deployment, browse to the URL and create your admin account.

### Step 5: Verify

```bash
kubectl get pods -n navidrome
# NAME                         READY   STATUS
# navidrome-7b9f854c7b-q58vs   1/1     Running

kubectl logs -n navidrome deployment/navidrome
# Should show scan progress of music library
```

## Configuration Details (values.yaml)

```yaml
replicaCount: 1

image:
  repository: deluan/navidrome
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 4533
  nodePort: 31433

storage:
  music:
    hostPath: /mnt/storage/music
    size: 100Gi
  data:
    hostPath: /mnt/storage/navidrome
    size: 5Gi

ingress:
  host: navidrome.lab.local

timezone: Asia/Kolkata
```

## Clients

Any Subsonic-compatible client can connect:

| Client | Platform | Notes |
|--------|----------|-------|
| **Ultrasonic** | Android | Recommended |
| **DSub** | Android | Good alternative |
| **Tempo** | iOS/macOS | Paid, polished |
| **Supersonic** | Desktop | Cross-platform |
| **Strawberry** | Linux | Music player with Subsonic support |

Server URL for clients: `https://deb-rish.tailb96c63.ts.net:4533`

## Maintenance

```bash
# Trigger a full rescan (if files changed outside watched folder)
# (Navidrome watches the music folder by default)

# View scan status
kubectl logs -n navidrome deployment/navidrome --tail=50

# Upgrade
helm upgrade --install navidrome apps/navidrome -n navidrome
```

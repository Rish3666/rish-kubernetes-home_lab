# Nextcloud

> Personal cloud — file sync, calendar, contacts, and more.
> Namespace: `nextcloud`

---

## Overview

Nextcloud deployed via the official Helm chart with external MariaDB and Redis. Provides file sync/Share, calendar (CalDAV), contacts (CardDAV), and various apps.

**Chart:** Official Nextcloud Helm chart (`nextcloud/nextcloud`)
**Image:** `nextcloud:stable`
**Namespace:** `nextcloud`
**Status:** Running (2/2 containers — apache + cron)

## Configuration

### Application

| Setting | Value |
|---------|-------|
| Host | `deb-rish.tailb96c63.ts.net` |
| Admin user | `admin` |
| Admin password | `Rish@363636` |
| Trusted domains | `deb-rish.tailb96c63.ts.net:8443` |

### Database

| Setting | Value |
|---------|-------|
| Type | External [[Databases#MariaDB]] |
| Host | `mariadb.databases.svc.cluster.local` |
| Database | `nextcloud` |
| User | `nextcloud` |
| Password | `ChangeNextcloudPassword123!` |

### Redis

| Setting | Value |
|---------|-------|
| Type | External [[Databases#Redis]] |
| Host | `redis-master.databases.svc.cluster.local` |
| Port | 6379 |
| Password | `YourStrongRedisPassword123!` |

### Storage

| Setting | Value |
|---------|-------|
| Type | Existing PVC |
| Claim | `nextcloud-data` |
| Size | 256Gi |
| Host path | `/mnt/storage/nextcloud` |
| StorageClass | `manual` |

### Resources

| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 1000m |
| Memory | 512Mi | 1Gi |

## Custom Configs

### Disable Rate Limiting
```php
$CONFIG['ratelimit.protection.enabled'] = false;
$CONFIG['auth.bruteforce.protection.enabled'] = false;
$CONFIG['auth.bruteforce.max-attempts'] = 9999;
```

### Force HTTPS
```php
$CONFIG['overwriteprotocol'] = 'https';
```

## Access

| Method | URL |
|--------|-----|
| Tailscale | `https://deb-rish.tailb96c63.ts.net:8443` |
| LAN (Traefik) | `https://deb-rish.tailb96c63.ts.net` or `http://192.168.0.112:30205` |

## Installation Guide

### Prerequisites

- [[Databases]] (MariaDB + Redis) deployed and running
- Persistent storage mounted at `/mnt/storage/nextcloud`
- Helm installed with Nextcloud repo:
  ```bash
  helm repo add nextcloud https://nextcloud.github.io/helm/
  helm repo update
  ```

### Step 1: Create Namespace

```bash
kubectl create namespace nextcloud
```

### Step 2: Create PersistentVolume + PVC

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nextcloud-data-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 256Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/storage/nextcloud
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nextcloud-data
  namespace: nextcloud
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 256Gi
EOF
```

### Step 3: Prepare values.yaml

Save as `apps/nextcloud/values.yaml`:

```yaml
nextcloud:
  host: deb-rish.tailb96c63.ts.net
  username: admin
  password: Rish@363636
  resources:
    requests:
      cpu: 100m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi
  trusted_domains:
    - deb-rish.tailb96c63.ts.net:8443
  configs:
    ratelimit.config.php: |-
      <?php
      $CONFIG = array (
        'ratelimit.protection.enabled' => false,
        'auth.bruteforce.protection.enabled' => false,
        'auth.bruteforce.max-attempts' => 9999,
      );
    overwriteprotocol.config.php: |-
      <?php
      $CONFIG = array (
        'overwriteprotocol' => 'https',
      );

internalDatabase:
  enabled: false

mariadb:
  enabled: false

externalDatabase:
  enabled: true
  type: mysql
  host: mariadb.databases.svc.cluster.local
  user: nextcloud
  password: ChangeNextcloudPassword123!
  database: nextcloud

redis:
  enabled: false

externalRedis:
  enabled: true
  host: redis-master.databases.svc.cluster.local
  port: "6379"
  password: YourStrongRedisPassword123!

ingress:
  enabled: true
  className: traefik
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web
  hosts:
    - host: deb-rish.tailb96c63.ts.net
      paths:
        - /
    - host: nextcloud.lab.local
      paths:
        - /
  tls: []

persistence:
  enabled: true
  existingClaim: nextcloud-data
  size: 256Gi

cronjob:
  enabled: true
```

### Step 4: Deploy Nextcloud

```bash
helm upgrade --install nextcloud oci://registry-1.docker.io/nextcloud/nextcloud \
  -n nextcloud -f apps/nextcloud/values.yaml --wait --timeout 10m
```

### Step 5: Initial Setup

If the Helm install runs `occ maintenance:install` automatically, it creates the admin user and database schema. If it fails (e.g., database timing), run manually:

```bash
kubectl exec -n nextcloud deployment/nextcloud -- occ maintenance:install \
  --database mysql \
  --database-host mariadb.databases.svc.cluster.local \
  --database-name nextcloud \
  --database-user nextcloud \
  --database-pass ChangeNextcloudPassword123! \
  --admin-user admin \
  --admin-pass Rish@363636
```

### Step 6: Fix Config Permissions

After install, the config.php ownership may need fixing:

```bash
kubectl exec -n nextcloud deployment/nextcloud -- chown www-data:www-data /var/www/html/config/config.php
```

### Step 7: Verify

```bash
kubectl get pods -n nextcloud
# NAME                         READY   STATUS
# nextcloud-5fff9dd4b5-8lln9   2/2     Running

kubectl logs -n nextcloud deployment/nextcloud
# Should show: "Nextcloud is ready"
```

## Maintenance

```bash
# Run occ commands
kubectl exec -n nextcloud deployment/nextcloud -- occ <command>

# Upgrade
helm upgrade --install nextcloud oci://registry-1.docker.io/nextcloud/nextcloud \
  -n nextcloud -f apps/nextcloud/values.yaml --wait --timeout 10m

# Force restart after config change
kubectl rollout restart -n nextcloud deployment/nextcloud

# Access database directly
kubectl exec -n databases mariadb-0 -- mysql -u nextcloud -p nextcloud
```

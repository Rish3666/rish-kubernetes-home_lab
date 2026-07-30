# Databases

> Shared MariaDB + Redis instance used by all applications.
> Namespace: `databases`

---

## Overview

Both databases live in the `databases` namespace and are shared by all services:

- **MariaDB** — relational database for [[Nextcloud]] (files, users, calendar, contacts)
- **Redis** — cache, lock management, and transactional file handling for [[Nextcloud]]

## MariaDB

**Chart:** Bitnami MariaDB (`bitnami/mariadb`)
**Architecture:** Standalone (single replica)

| Setting | Value |
|---------|-------|
| Database | `nextcloud` |
| User | `nextcloud` |
| Password | `ChangeNextcloudPassword123!` |
| Storage | 20Gi (via `local-path` StorageClass) |
| Service | `mariadb.databases.svc.cluster.local:3306` |
| Root Password | `ChangeRootPassword123!` |
| CPU Request/Limit | 100m / 1000m |
| Memory Request/Limit | 256Mi / 1Gi |

## Redis

**Chart:** Bitnami Redis (`bitnami/redis`)
**Architecture:** Standalone (master only, no replicas)

| Setting | Value |
|---------|-------|
| Auth enabled | Yes |
| Password | `YourStrongRedisPassword123!` |
| Storage | 5Gi (via `local-path` StorageClass) |
| Service | `redis-master.databases.svc.cluster.local:6379` |
| CPU Request/Limit | 50m / 500m |
| Memory Request/Limit | 128Mi / 512Mi |

## Installation Guide

### Prerequisites

- K3s cluster running (see [[Bootstrap#K3s]])
- Helm installed with Bitnami repo added:
  ```bash
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo update
  ```

### Step 1: Create Namespace

```bash
kubectl create namespace databases
```

### Step 2: Deploy MariaDB

```bash
helm upgrade --install mariadb bitnami/mariadb -n databases \
  --set auth.rootPassword=ChangeRootPassword123! \
  --set auth.database=nextcloud \
  --set auth.username=nextcloud \
  --set auth.password=ChangeNextcloudPassword123! \
  --set primary.persistence.size=20Gi \
  --set primary.resources.requests.cpu=100m \
  --set primary.resources.requests.memory=256Mi \
  --set primary.resources.limits.cpu=1000m \
  --set primary.resources.limits.memory=1Gi \
  --set architecture=standalone \
  --wait --timeout 5m
```

### Step 3: Deploy Redis

```bash
helm upgrade --install redis bitnami/redis -n databases \
  --set auth.enabled=true \
  --set auth.password=YourStrongRedisPassword123! \
  --set master.persistence.size=5Gi \
  --set master.resources.requests.cpu=50m \
  --set master.resources.requests.memory=128Mi \
  --set master.resources.limits.cpu=500m \
  --set master.resources.limits.memory=512Mi \
  --set replica.replicaCount=0 \
  --wait --timeout 5m
```

### Step 4: Verify

```bash
kubectl get pods -n databases
# NAME            READY   STATUS
# mariadb-0       1/1     Running
# redis-master-0  1/1     Running

kubectl get svc -n databases
# NAME            TYPE        CLUSTER-IP      PORT(S)
# mariadb         ClusterIP   10.43.161.49    3306/TCP
# redis-master    ClusterIP   10.43.233.200   6379/TCP
```

## Connecting from Applications

```yaml
# MariaDB connection string
mariadb.databases.svc.cluster.local:3306

# Redis connection string
redis-master.databases.svc.cluster.local:6379
```

Applications in the cluster can reach these via their Kubernetes DNS names. See [[Nextcloud]] for how the apps use them.

## Maintenance

```bash
# Get MariaDB root password
kubectl get secret -n databases mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 -d

# Get Redis password
kubectl get secret -n databases redis -o jsonpath="{.data.redis-password}" | base64 -d

# Connect to MariaDB
kubectl exec -n databases mariadb-0 -- mysql -u root -p

# Connect to Redis
kubectl exec -n databases redis-master-0 -- redis-cli -a <password>

# Backup MariaDB
kubectl exec -n databases mariadb-0 -- mysqldump -u root -p nextcloud > nextcloud_backup.sql
```

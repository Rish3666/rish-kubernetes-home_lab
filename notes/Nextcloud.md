# Nextcloud

**Deployment:** Official Nextcloud Helm chart (`oci://registry-1.docker.io/nextcloud/nextcloud`)  
**Namespace:** `nextcloud`  
**Status:** Running (2/2 containers — app + cron)

---

## Configuration

| Setting | Value |
|---------|-------|
| Host | `rishlab.tailb96c63.ts.net` |
| Admin user | `admin` |
| Admin password | `Rish@363636` |
| Trusted domains | `rishlab.tailb96c63.ts.net:8443` |

---

## Database

| Setting | Value |
|---------|-------|
| Type | External MariaDB |
| Host | `mariadb.databases.svc.cluster.local` |
| Database | `nextcloud` |
| User | `nextcloud` |
| Password | `ChangeNextcloudPassword123!` |

---

## Redis

| Setting | Value |
|---------|-------|
| Host | `redis-master.databases.svc.cluster.local` |
| Port | 6379 |
| Password | `YourStrongRedisPassword123!` |

---

## Storage

| Setting | Value |
|---------|-------|
| Type | Existing PVC |
| Claim | `nextcloud-data` |
| Size | 256Gi |
| Host path | `/mnt/storage/nextcloud` |

---

## Custom Configs

### Disable Rate Limiting (`ratelimit.config.php`)
```php
<?php
$CONFIG = [
  'ratelimit.enabled' => 'false',
  'auth.bruteforce.protection.enabled' => 'false',
];
```

### Force HTTPS (`overwriteprotocol.config.php`)
```php
<?php
$CONFIG = [
  'overwriteprotocol' => 'https',
];
```

---

## Access

| Method | URL |
|--------|-----|
| Internal (Tailscale) | `https://rishlab.tailb96c63.ts.net:8443` |
| Internal (lab.local) | `https://nextcloud.lab.local` |

---

## Resources

| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 1000m |
| Memory | 512Mi | 1Gi |
# Nextcloud

**Chart:** Official Nextcloud Helm chart  
**Namespace:** `nextcloud`  
**Status:** Running (2/2 containers)

> See also: [[Databases]], [[Architecture]], [[Networking]], [[Bootstrap#Nextcloud]]

---

## Configuration

| Setting | Value |
|---------|-------|
| Host | `rishlab.tailb96c63.ts.net` |
| Admin user | `admin` |
| Trusted domains | `rishlab.tailb96c63.ts.net:8443` |

---

## Database

| Setting | Value |
|---------|-------|
| Type | External [[Databases#MariaDB]] |
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

Details: [[Storage]]

---

## Custom Configs

### Disable Rate Limiting
```php
$CONFIG['ratelimit.enabled'] = 'false';
$CONFIG['auth.bruteforce.protection.enabled'] = 'false';
```

### Force HTTPS
```php
$CONFIG['overwriteprotocol'] = 'https';
```

---

## Access

| Method | URL |
|--------|-----|
| Internal (Tailscale) | `https://rishlab.tailb96c63.ts.net:8443` |
| Internal (lab.local) | `https://nextcloud.lab.local` |
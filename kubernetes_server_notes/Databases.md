# Databases

Both databases live in the `databases` namespace and are shared by all services.

> See also: [[Kubernetes]], [[Nextcloud]], [[Architecture]]

---

## MariaDB

**Chart:** Bitnami MariaDB  
**Architecture:** Standalone

| Setting | Value |
|---------|-------|
| Database | `nextcloud` |
| User | `nextcloud` |
| Password | `ChangeNextcloudPassword123!` |
| Storage | 20Gi |
| Service | `mariadb.databases.svc.cluster.local:3306` |

---

## Redis

**Chart:** Bitnami Redis  
**Architecture:** Standalone

| Setting | Value |
|---------|-------|
| Auth enabled | Yes |
| Password | `YourStrongRedisPassword123!` |
| Storage | 5Gi |
| Service | `redis-master.databases.svc.cluster.local:6379` |

---

## Usage

[[Nextcloud]] connects to both:
- MariaDB for relational data (files, users, calendar, contacts)
- Redis for caching, lock management, and transactional file handling

```yaml
# Nextcloud database config
db:
  host: mariadb.databases.svc.cluster.local
  name: nextcloud
  user: nextcloud
  password: ChangeNextcloudPassword123!

redis:
  host: redis-master.databases.svc.cluster.local
  port: 6379
  password: YourStrongRedisPassword123!
```

---

## Deployment

These are deployed via [[Bootstrap#Databases]] — the bootstrap script handles it automatically.
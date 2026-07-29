# Databases

Both databases live in the `databases` namespace and are shared by all services.

---

## MariaDB

**Chart:** Bitnami MariaDB (`oci://registry-1.docker.io/bitnamicharts/mariadb`)  
**Architecture:** Standalone (single instance)

### Configuration
| Setting | Value |
|---------|-------|
| Root password | `ChangeRootPassword123!` |
| Database | `nextcloud` |
| User | `nextcloud` |
| User password | `ChangeNextcloudPassword123!` |
| Storage | 20Gi (`local-path` storage class) |
| Resources | requests: 100m CPU / 256Mi RAM, limits: 1000m CPU / 1Gi RAM |

### Service
- **Name:** `mariadb.databases.svc.cluster.local`
- **Port:** 3306

### Restarts
~88 restarts (27 days) — related to node reboots during development.

---

## Redis

**Chart:** Bitnami Redis (`oci://registry-1.docker.io/bitnamicharts/redis`)  
**Architecture:** Standalone (replicas: 0)

### Configuration
| Setting | Value |
|---------|-------|
| Auth enabled | Yes |
| Password | `YourStrongRedisPassword123!` |
| Storage | 5Gi (`local-path` storage class) |
| Resources | requests: 50m CPU / 128Mi RAM, limits: 500m CPU / 512Mi RAM |

### Service
- **Name:** `redis-master.databases.svc.cluster.local`
- **Port:** 6379

### Restarts
~88 restarts (27 days) — same as MariaDB.

---

## Usage

Nextcloud connects to both:
- MariaDB for relational data (files, users, calendar, contacts)
- Redis for caching, lock management, and transactional file handling

```yaml
# Nextcloud database config
db:
  host: mariadb.databases.svc.cluster.local
  name: nextcloud
  user: nextcloud
  password: ChangeNextcloudPassword123!

# Nextcloud Redis config
redis:
  host: redis-master.databases.svc.cluster.local
  port: 6379
  password: YourStrongRedisPassword123!
```
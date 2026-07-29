# Kubernetes (K3s)

## Overview

Single-node K3s cluster. No kube-proxy pod — K3s uses its embedded proxy.

**Version:** v1.36.2+k3s1  
**Container runtime:** containerd 2.3.2-k3s2  
**Node:** `rishlab` (control-plane)

---

## Namespaces

| Namespace | Purpose | Age |
|-----------|---------|-----|
| `databases` | MariaDB + Redis | 27d |
| `glance` | Dashboard | 19d |
| `navidrome` | Music streaming | 28d |
| `nextcloud` | File sync | 27d |
| `kube-system` | System pods | 28d |
| `default` | Default | 28d |

---

## Key Pods

```
NAMESPACE     NAME                                     READY   STATUS
databases     mariadb-0                                1/1     Running
databases     redis-master-0                           1/1     Running
glance        glance-78885dcf69-tb2r5                  1/1     Running
kube-system   coredns-5f5694d56b-m5rp2                 1/1     Running
kube-system   local-path-provisioner-58d557dc48-pcvj9  1/1     Running
kube-system   metrics-server-7c86f97b8d-vjjr9          1/1     Running
kube-system   svclb-traefik-d81f755d-46pn4             2/2     Running
kube-system   traefik-6cd8c7cd89-z5qn7                 1/1     Running
navidrome     navidrome-7b9f854c7b-q58vs               1/1     Running
nextcloud     nextcloud-5fff9dd4b5-8lln9               2/2     Running
```

---

## Services

| Namespace | Service | Type | Cluster IP | Port(s) |
|-----------|---------|------|------------|---------|
| databases | mariadb | ClusterIP | 10.43.161.49 | 3306 |
| databases | mariadb-headless | ClusterIP | None | 3306 |
| databases | redis-master | ClusterIP | 10.43.233.200 | 6379 |
| databases | redis-headless | ClusterIP | None | 6379 |
| glance | glance | ClusterIP | 10.43.176.98 | 8080 |
| kube-system | traefik | LoadBalancer | 10.43.152.162 | 80:30205, 443:32184 |
| kube-system | kube-dns | ClusterIP | 10.43.0.10 | 53 |
| kube-system | metrics-server | ClusterIP | 10.43.113.12 | 443 |
| navidrome | navidrome | NodePort | 10.43.110.134 | 4533:31433 |
| nextcloud | nextcloud | ClusterIP | 10.43.170.52 | 8080 |

---

## Ingresses

| Service | Host | Class |
|---------|------|-------|
| Glance | `glance.lab.local` | traefik |
| Navidrome | `navidrome.lab.local` | traefik |
| Nextcloud | `rishlab.tailb96c63.ts.net` | traefik |

---

## Persistent Volumes

| Volume | Size | Access | Claim | StorageClass |
|--------|------|--------|-------|-------------|
| navidrome-data-pv | 5Gi | RWO | navidrome/navidrome-data-pvc | manual |
| navidrome-music-pv | 100Gi | RWO | navidrome/navidrome-music-pvc | manual |
| nextcloud-data-pv | 256Gi | RWO | nextcloud/nextcloud-data | manual |
| minecraft-pv | 50Gi | RWO | (Released) | minecraft-storage |

---

## Commands Cheatsheet

```bash
# Get all pods
kubectl get pods -A -o wide

# Get all services
kubectl get svc -A

# Follow logs
kubectl logs -f -n <ns> <pod>

# Describe pod (for failures)
kubectl describe pod -n <ns> <pod>

# Get node status
kubectl get nodes -o wide

# Helm list
helm list -A
```
# Kubernetes (K3s)

> See also: [[Architecture]], [[Databases]], [[Bootstrap#K3s]]

---

## Overview

Single-node K3s cluster. No kube-proxy pod — K3s uses its embedded proxy.

| Setting | Value |
|---------|-------|
| Version | v1.36.2+k3s1 |
| Container runtime | containerd 2.3.2-k3s2 |
| Node | `deb-rish` (control-plane) |
| API Server | `https://192.168.0.112:6443` |
| Data dir | `/mnt/storage/k3s/rancher` (symlinked from `/var/lib/rancher`) |

## Namespaces

| Namespace | Purpose |
|-----------|---------|
| `databases` | Shared [[Databases]] (MariaDB + Redis) |
| `glance` | [[Glance]] Dashboard |
| `navidrome` | [[Navidrome]] Music |
| `nextcloud` | [[Nextcloud]] Files |
| `kube-system` | System pods (coredns, traefik, local-path-provisioner, metrics-server) |

## Key Pods

```
NAMESPACE     NAME                                     READY   STATUS
databases     mariadb-0                                1/1     Running
databases     redis-master-0                           1/1     Running
glance        glance-78885dcf69-tb2r5                  1/1     Running
navidrome     navidrome-7b9f854c7b-q58vs               1/1     Running
nextcloud     nextcloud-5fff9dd4b5-8lln9               2/2     Running
kube-system   coredns-...                              1/1     Running
kube-system   local-path-provisioner-...                1/1     Running
kube-system   metrics-server-...                        1/1     Running
kube-system   helm-install-traefik-...                  0/1     Completed
kube-system   traefik-...                               1/1     Running
```

## Services

| Namespace | Service | Type | Cluster IP | Port(s) |
|-----------|---------|------|------------|---------|
| databases | mariadb | ClusterIP | 10.43.161.49 | 3306 |
| databases | redis-master | ClusterIP | 10.43.233.200 | 6379 |
| glance | glance | ClusterIP | 10.43.176.98 | 8080 |
| navidrome | navidrome | NodePort | 10.43.110.134 | 4533:31433 |
| nextcloud | nextcloud | ClusterIP | 10.43.170.52 | 8080 |
| kube-system | traefik | LoadBalancer | 10.43.152.162 | 80:30205, 443:32184 |

## Ingresses

| Service | Host | Class |
|---------|------|-------|
| [[Glance]] | `glance.lab.local` | traefik |
| [[Navidrome]] | `navidrome.lab.local` | traefik |
| [[Nextcloud]] | `deb-rish.tailb96c63.ts.net` | traefik |

Additionally, `nextcloud.lab.local` is configured as a secondary host for Nextcloud.

## Persistent Volumes

| Volume | Size | Claim | StorageClass |
|--------|------|-------|-------------|
| navidrome-data-pv | 5Gi | navidrome/navidrome-data-pvc | manual |
| navidrome-music-pv | 100Gi | navidrome/navidrome-music-pvc | manual |
| nextcloud-data-pv | 256Gi | nextcloud/nextcloud-data | manual |

Details: [[Storage]]

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

# Helm list
helm list -A

# Watch node status
kubectl get nodes -w

# Get all events sorted by time
kubectl get events -A --sort-by='.lastTimestamp'
```

For failures: [[Troubleshooting#Kubernetes]]

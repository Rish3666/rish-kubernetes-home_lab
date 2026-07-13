# RishLab — K3s Homelab

Infrastructure-as-code for a single-node [K3s](https://k3s.io/) cluster running on a home server. All apps are deployed via Helm with Tailscale networking, Traefik ingress, and centralized databases.

---

## Prerequisites

| Tool    | Purpose                          | Install                                                         |
|---------|----------------------------------|-----------------------------------------------------------------|
| Linux   | Host OS (tested on Debian 13) | —                                                               |
| K3s     | Lightweight Kubernetes           | `curl -sfL https://get.k3s.io \| sh -`                          |
| Helm    | Kubernetes package manager       | `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \| bash` |
| kubectl | Kubernetes CLI                   | Included with K3s (`kubectl` alias set via `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml`) |
| Tailscale | Secure mesh VPN                | `curl -fsSL https://tailscale.com/install.sh \| sh`              |

After installing K3s, export your kubeconfig:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# Add to ~/.bashrc for persistence
```

---

## Hardware

This homelab runs on a repurposed **HP All-in-One 22-c0xx** desktop. Below are the full specs and rationale for using repurposed hardware.

| Component | Detail |
|-----------|--------|
| **Model** | HP All-in-One 22-c0xx (103C_53311M HP OPP) |
| **Chassis** | All-in-One (integrated 21.5" 1920x1080 display) |
| **CPU** | Intel Pentium Silver J5005 (Gemini Lake) — 4 cores, 4 threads, 1.5 GHz base / 2.8 GHz burst, 4 MB L2 cache, 6W TDP |
| **GPU** | Intel UHD Graphics 605 (Gemini Lake, i915 driver) |
| **RAM** | 8 GB DDR4-2666 (single SODIMM in DIMM1, DIMM0 empty) — upgradable to 32 GB max |
| **OS Drive** | 120 GB Secureye SATA SSD (OS + K3s + container images) |
| **Storage** | 1 TB Toshiba DT01ACA100 7200 RPM SATA HDD (music, nextcloud data, app data) |
| **External** | 1 TB WD Blue WD10JPVX 5400 RPM USB 3.0 HDD (backup / spare) |
| **NIC** | Realtek RTL8111/8168 Gigabit Ethernet |
| **WiFi** | Realtek RTL8821CE 802.11ac (disabled — not used) |
| **Bluetooth** | Realtek Bluetooth 4.2 (included with WiFi card) |
| **Optical** | DVDRW GUD1N SATA (unused) |
| **Idle Power** | ~15–18 W at the wall (measured with a Kill-A-Watt) |
| **Under Load** | ~25–30 W (K3s + all apps running) |
| **Annual Cost** | ~$20–30/year at typical US electricity rates (headless, 24/7) |
| **OS** | Debian 13 (Trixie) — no GUI, boots to multi-user.target |
| **Kernel** | 6.12.x |

### Why an All-in-One?

| Factor | Note |
|--------|------|
| **Cost** | This machine was free (e-waste). Repurposing beats buying a Raspberry Pi or NUC. |
| **Built-in UPS** | The integrated LCD draws ~5 W at idle, but also includes a capable 65 W PSU with enough headroom for 2× 3.5" HDDs. A separate UPS is optional. |
| **Display** | The 21.5" panel is power-gated via DRM DPMS at boot (see `scripts/panel-off.service`). After blanking, the system draws the same power as a headless mini PC. |
| **PCIe** | One empty M.2 key-E slot (used by WiFi), no expandability beyond USB/SATA. Not a concern for a single-node cluster. |
| **Fan Noise** | Single 92 mm chassis fan + PSU fan. Barely audible at idle. HDD spin-up is the loudest event. |

### Resource Headroom

With K3s + Navidrome + Nextcloud + MariaDB + Redis + Glance + Flannel:

```
Memory:  2.6 GiB used / 7.5 GiB total  →  ~35% used,  ~65% free
CPU:    ~5–15% idle  →  J5005 spends most of its time asleep
Disk:    30 GiB used / 113 GiB root    →  plenty for container images
Storage: 150 GiB used / 931 GiB HDD    →  room to grow
```

The J5005 is a 6W TDP SoC — it's *slow* (Passmark ~2200), but for file serving, music streaming, and light Kubernetes it's more than adequate.

---

## Hardware Suggestions

If you don't have an old All-in-One lying around, here are alternatives that would run this same setup equally well or better.

### Minimal / Low Power (< 15 W)

| Device | CPU | RAM | Storage | Pros | Cons |
|--------|-----|-----|---------|------|------|
| **Raspberry Pi 5** | Cortex-A76 4C @ 2.4 GHz | 8 GB | microSD + USB SSD | $80, 5–10 W, huge community | No x86 (ARM64 only), 8 GB RAM ceiling, no ECC |
| **Radxa Rock 5B** | RK3588 (4× A76 + 4× A55) | 16 GB | NVMe + microSD | 16 GB RAM, PCIe NVMe, USB3 | ARM64, less community than RPi |
| **Used Thin Client** (Dell Wyse 5070, HP t740) | Intel J5005/N5000 | 8–16 GB | M.2 SATA | $50–100, x86, very low power | Limited expansion, single DIMM |
| **Used NUC** (NUC7/NUC8) | Intel i3/i5 7th–8th gen | 16–32 GB | M.2 NVMe + SATA | $80–150, very capable, 2× SODIMM | No built-in storage, no display (fine for headless) |

### Recommended / Sweet Spot (15–35 W)

| Device | CPU | RAM | Storage | Pros | Cons |
|--------|-----|-----|---------|------|------|
| **Used Dell Optiplex Micro** (3040/3050/3060) | Intel i5-6500T / i5-8500T | 16–32 GB | M.2 + 2.5" SATA | $80–120, Tiny form factor, very quiet, USB-C DP Alt, 1× GbE, can add 2.5 GbE via M.2 key-E | Single SODIMM on some models |
| **Used HP EliteDesk 800 G3/G4 Mini** | Intel i5-6500T / i5-8500T | 16–32 GB | M.2 + 2.5" SATA | $70–110, Very small, 6× USB, DP + VGA, W19 slot | 1× GbE only (add 2.5 GbE via USB) |
| **Used Lenovo M720q / M920q Tiny** | Intel i5-8500T / i7-8700T | 32 GB | M.2 + 2.5" SATA | $100–150, Can fit a PCIe riser for 2.5 GbE or 4-port NIC, great K3s node | Slightly pricier |
| **ASUS N100/N150/N300 mini** | Intel N100 (4× Alder Lake-N) | 16–32 GB | M.2 NVMe | $120–150 new, 6W TDP, AV1 decode, DDR5, dual GbE | No ECC, single channel RAM limited to 16 GB / 32 GB depending on model |

### Overkill (but awesome) — Multi-Node Cluster

| Device | Role | Why |
|--------|------|-----|
| **3× HP EliteDesk 800 G4 Mini** | 3-node K3s cluster | $300–400 total. Run control-plane on all 3, HA with embedded etcd. 10× the headroom for < 60 W total. |
| **1× ODROID-H4+** | Single-node cluster | N305 (8× Alder Lake-N), 32 GB DDR5, 2× 2.5 GbE, M.2 NVMe + SATA. $200. Best low-power x86 SBC. |

### Niche / Unusual Setups

| Setup | Description |
|-------|-------------|
| **Laptop with a cracked screen** | The most common e-waste. Lid closed, DPMS Off on the internal panel. Same panel-off.service works. Even better: laptop has a built-in battery-UPS and WiFi. Downside: fan noise under load, hinge wear. |
| **Old Chromebook** (x86 model) | Flash Coreboot/SeaBIOS, install Debian. The USB-C charger doubles as the PSU. Very power-efficient (5–10 W). Limited to 4–8 GB RAM (soldered). |
| **Thin Client + USB HDD** | HP t740, Dell Wyse 5070, Fujitsu Futro S920. $30–60 on eBay. J5000/J5005 based, desktop idle power ~6 W. Add a USB 3.0 enclosure for bulk storage. Perfect for Navidrome. |
| **Repurposed Cable Box / DVR** | Older TiVo, Sky box, or cable DVR with a SATA port and a Linux-capable SoC. Flashing custom firmware turns them into low-power Linux boxes. The eMMC is tiny, so you'll boot from USB. Niche, but cheap. |
| **VM / LXC on your main PC** | Run the whole stack as VMs or LXC containers on your daily driver. No extra hardware, no power cost. Great for testing, but not 24/7 if your main PC goes to sleep. |
| **Hetzner CX22 / CX32 Cloud VM** | 2 vCPU + 4 GB RAM, €3.79/mo. Full K3s, public IP, no power/noise. $45/year beats buying hardware if you don't need local storage. Add a Volume (€0.05/GB/mo) for music/nextcloud. |
| **Router-as-a-Server** | If you run OPNsense/pfSense/OpenWrt on x86 hardware, you already have a 24/7 Linux box. Spin up a K3s node next to your firewall. Only do this if you have ample RAM and storage on the router. |

### Key Considerations for Any Hardware

| Factor | Advice |
|--------|--------|
| **RAM** | 8 GB minimum. 16 GB recommended for Nextcloud + Navidrome + Redis + monitoring. K3s itself uses ~1 GB. |
| **Storage** | Separate OS disk (SSD) from data disk (HDD or large SSD). K3s container images fill up small SSDs fast. Use `hostPath` PVs for music/nextcloud data on the big HDD. |
| **Networking** | 1 GbE is fine for music streaming + file sync. If you run Jellyfin with transcoding or large Nextcloud syncs, consider 2.5 GbE via USB adapter or M.2 key-E NIC. |
| **Power** | For a 24/7 server, every watt matters: 10 W × 8760 h = 87.6 kWh/year ≈ $13/year. A NUC at 20 W costs ~$26/year. Factor this into your hardware budget. |
| **ECC RAM** | Not needed for a homelab. Bit flips happen, but ZFS on the data HDD protects against silent corruption. For the OS SSD, daily restic or borg backups cover you. |
| **Silence** | If the machine lives in your bedroom/living room, prioritize passive-cooled or large-slow-fan designs. Thin clients and NUCs are nearly silent. Old HDDs are the loudest component. |

```
~/rishlab/
├── apps/                    # Application Helm values & charts
│   ├── nextcloud/           #   Nextcloud values (external DB)
│   └── navidrome/           #   Navidrome local Helm chart
├── charts/                  # Custom Helm charts
│   └── glance/              #   Glance dashboard
├── databases/               # Centralized shared databases
│   ├── mariadb/             #   MariaDB values
│   └── redis/               #   Redis values
├── backups/                 # Backup configs (planned)
│   ├── restic/
│   └── velero/
├── monitoring/              # Monitoring stack (planned)
│   ├── alloy/
│   ├── grafana/
│   ├── loki/
│   └── prometheus/
├── networking/              # Networking configs (planned)
│   ├── cert-manager/
│   ├── tailscale/
│   └── traefik/
├── storage/                 # Storage configs (planned)
│   ├── longhorn/
│   └── nfs/
├── scripts/                 # Utility scripts
├── docs/                    # Notes and documentation
├── README.md
└── .gitignore
```

---

## Architecture: Centralized Databases

All applications share a single MariaDB and Redis instance in the `databases` namespace. This avoids running a database per app and reduces resource usage on a single-node cluster.

```
┌─────────────────────────────────────────────────────────────┐
│                     databases namespace                     │
│  ┌──────────┐  ┌────────────┐                               │
│  │  MariaDB │  │   Redis    │                               │
│  │  :3306   │  │   :6379    │                               │
│  └────┬─────┘  └─────┬──────┘                               │
│       │              │                                       │
└───────┼──────────────┼───────────────────────────────────────┘
        │              │
        │     ┌────────┼────────┐
        │     │        │        │
   ┌────┴─────┴──┐ ┌──┴────────┴───┐
   │  Nextcloud  │ │   Navidrome   │
   └─────────────┘ └───────────────┘
│                     apps namespace                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Deployment

### 1. Centralized Databases

Create the `databases` namespace and deploy MariaDB + Redis:

```bash
kubectl create namespace databases

# MariaDB
helm upgrade --install mariadb oci://registry-1.docker.io/bitnamicharts/mariadb \
  -n databases -f databases/mariadb/values.yaml --wait

# Redis
helm upgrade --install redis oci://registry-1.docker.io/bitnamicharts/redis \
  -n databases -f databases/redis/values.yaml --wait
```

Verify they're running:

```bash
kubectl get pods -n databases
```

### 2. Applications

#### Nextcloud

Change admin password first in `apps/nextcloud/values.yaml`:

```yaml
nextcloud:
  username: admin
  password: YourSecurePassword  # ← Change this
```

Then deploy:

```bash
kubectl create namespace nextcloud

helm upgrade --install nextcloud oci://registry-1.docker.io/nextcloud/nextcloud \
  -n nextcloud -f apps/nextcloud/values.yaml --wait
```

**Note:** This config disables the bundled MariaDB and Redis in favor of the centralized ones in the `databases` namespace.

#### Navidrome

Navidrome uses a local Helm chart with `hostPath` PersistentVolumes. First create the data and music directories on the host:

```bash
sudo mkdir -p /mnt/storage/navidrome /mnt/storage/music
sudo chown -R 1000:1000 /mnt/storage/navidrome /mnt/storage/music
```

Adjust paths in `apps/navidrome/values.yaml` if needed:

```yaml
storage:
  music:
    hostPath: /mnt/storage/music   # Your music library path
    size: 100Gi
  data:
    hostPath: /mnt/storage/navidrome
    size: 5Gi
```

Then deploy:

```bash
kubectl create namespace navidrome

helm upgrade --install navidrome ./apps/navidrome \
  -n navidrome
```

#### Glance Dashboard

Glance is deployed via a local Helm chart at `charts/glance/`. It provides a unified dashboard with search, server stats, service monitoring, GitHub profile/commits, videos, and Hacker News:

```bash
kubectl create namespace glance

helm upgrade --install glance ./charts/glance \
  -n glance
```

Access via Tailscale Serve at `https://rishlab.tailb96c63.ts.net:4443`.
```

---

## Customizing for Your Own Cluster

1. **Change all passwords** — Search the entire repo for placeholder passwords and replace them:
   - `ChangeRootPassword123!` (MariaDB root)
   - `ChangeNextcloudPassword123!` (MariaDB nextcloud user)
   - `YourStrongRedisPassword123!` (Redis)
   - `Rish@363636` (Nextcloud admin)

2. **Update hostnames** — Replace `*.tailb96c63.ts.net` with your own Tailscale MagicDNS suffix or domain in:
   - `apps/nextcloud/values.yaml`
   - Navidrome ingress template (optional — add `host:` field)

3. **Adjust storage paths** — Update `hostPath` in Navidrome PV templates and Nextcloud persistence config to match your server's mount points.

4. **Tweak resources** — CPU/memory requests and limits are conservative for a small server. Adjust based on your hardware.

---

## Networking

### Tailscale + MagicDNS

This cluster uses [Tailscale](https://tailscale.com/) for secure, private networking with MagicDNS. The default Tailscale hostname is `rishlab.tailb96c63.ts.net`. Services are exposed through:

- **Traefik ingress controller** (K3s default, on port 80/443)
- **Tailscale IP** (tailscale0 interface, accessible by any device on your tailnet)

### Tailscale Serve (Port-Based Access)

Services are exposed via **[Tailscale Serve](https://tailscale.com/kb/1311/serve)** on distinct ports (tailnet only):

| Service    | URL                                             | Backend                        |
|------------|-------------------------------------------------|--------------------------------|
| Glance     | `https://rishlab.tailb96c63.ts.net:4443`        | `http://glance.glance:8080`    |
| Navidrome  | `https://rishlab.tailb96c63.ts.net:4533`        | `http://navidrome.navidrome:4533` |
| Nextcloud  | `https://rishlab.tailb96c63.ts.net:8443`        | `http://nextcloud.nextcloud:8080` |

Port 443 on the Tailscale IP is blocked by K3s CNI iptables DNAT rules, so port-based access via Tailscale Serve is the primary tailnet access method. Each service is also accessible via Traefik Ingress on the cluster-internal `*.lab.local` hostnames.

### Traefik Dashboard

K3s ships with Traefik by default. Access the dashboard:

```bash
kubectl port-forward -n kube-system deployment/traefik 8080:9000
# Open http://localhost:8080/dashboard/
```

---

## Stack Overview

| Component   | Namespace   | Purpose             | Deployment Method            |
|-------------|-------------|---------------------|------------------------------|
| MariaDB     | databases   | Relational DB       | Bitnami Helm chart           |
| Redis       | databases   | Cache / session     | Bitnami Helm chart           |
| Nextcloud   | nextcloud   | File sync & share   | Official Helm chart          |
| Navidrome   | navidrome   | Music streaming     | Local Helm chart (hostPath)  |
| Glance      | glance      | Dashboard / start page | Local Helm chart (charts/glance/) |

### Planned Additions

- Authentik — Identity provider / SSO
- Immich — Photo backup
- Jellyfin — Media server
- Paperless-ngx — Document management
- Gitea / Forgejo — Git hosting
- Grafana + Prometheus + Loki — Monitoring & logging
- cert-manager + Let's Encrypt — Automatic TLS
- Longhorn — Distributed block storage
- Harbor — Container registry
- ArgoCD — GitOps deployment

---

## Troubleshooting

### Pod stuck at Init/ContainerCreating

Check persistent volumes exist:

```bash
kubectl get pv,pvc -A
```

For hostPath volumes, verify the directory exists on the node.

### Nextcloud fails to connect to MariaDB

Ensure MariaDB is running and the database/credentials match `externalDatabase` in `apps/nextcloud/values.yaml`:

```bash
kubectl exec -n databases deploy/mariadb -- mysql -u nextcloud -p"$MARIADB_PASSWORD" -e "SHOW DATABASES;"
```

### Navidrome shows "decryption panicked" on login

The password was encrypted with a different key. Use the Navidrome CLI to reset it:

```bash
kubectl exec -n navidrome deploy/navidrome -it -- /app/navidrome user edit --set-password -u <username> --datafolder /data
```

### Tailscale Serve port not accessible

Ensure Tailscale Serve is running with the correct backend IP:

```bash
sudo tailscale serve status
```

If the backend ClusterIP changed (e.g., after `helm delete`/`helm install`), update Tailscale Serve:

```bash
sudo tailscale serve --https=4443 --bg http://<new-clusterip>:8080
```

---

## License

This is a personal homelab configuration. Feel free to fork and adapt for your own use.

# Hardware

**Model:** HP All-in-One 22-c0xx (103C_53311M HP OPP)
**Chassis:** 21.5" 1920x1080 display (power-gated at boot via fbdev DPMS)

See: [[Architecture]], [[Storage]], [[Bootstrap#Hardware Prep]]

---

## CPU

| Spec | Value |
|------|-------|
| Model | Intel Pentium Silver J5005 |
| Architecture | Gemini Lake |
| Cores/Threads | 4 / 4 |
| Base Clock | 1.50 GHz |
| Burst Clock | 2.80 GHz |
| L2 Cache | 4 MB |
| TDP | 6W |
| Passmark | ~2200 |

---

## RAM

| Spec | Value |
|------|-------|
| Total | 8 GB |
| Type | DDR4-2666 |
| Slots | 2 (DIMM0 empty, DIMM1 populated) |
| Max | 32 GB |

**Upgrade planned** — see [[Future-Plans#Other Ideas]]

---

## GPU

| Spec | Value |
|------|-------|
| Model | Intel UHD Graphics 605 |
| Driver | i915 (Gemini Lake) |

---

## Storage

| Device | Size | Type | Mount | Purpose |
|--------|------|------|-------|---------|
| `/dev/sda` | 120 GB | Secureye SATA SSD | `/` (111G avail) | OS, [[Kubernetes]], container images |
| `/dev/sdb` | 1 TB | Toshiba DT01ACA100 (7200 RPM) | `/mnt/storage` | App data: [[Navidrome]], [[Nextcloud]], [[Minecraft]] |
| `/dev/sdc` | 1 TB | WD Blue WD10JPVX (5400 RPM, USB 3.0) | (unmounted) | Backup / spare |

Details: [[Storage]]

---

## Network

| Interface | Spec |
|-----------|------|
| Ethernet | Realtek RTL8111/8168 Gigabit — `192.168.0.250` |
| WiFi | Realtek RTL8821CE 802.11ac (disabled) |
| Bluetooth | Realtek Bluetooth 4.2 (disabled) |

Details: [[Networking]]

---

## Power

| State | Draw |
|-------|------|
| Idle | ~15-18W |
| Load | ~25-30W |
| Annual cost | ~$20-30/year |

---

## OS

| Spec | Value |
|------|-------|
| OS | Debian 13 (Trixie) |
| Kernel | 6.12.96+deb13-amd64 |
| Mode | No GUI, boots to multi-user.target |
| K3s | v1.36.2+k3s1 |
| containerd | 2.3.2-k3s2 |
| Docker | 29.6.1 (via snap) |

Switching distros? Use [[Bootstrap]] for a fresh start.
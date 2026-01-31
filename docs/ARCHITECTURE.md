# Multi-node declarative Incus architecture (reference summary)

This document is a **concise but complete reference** for the multi-node, declarative Incus architecture we established.  
It is intended to be both **human-readable** and **LLM-consumable** as a future starting point.

---

## 1. Scope and goals

### Primary goals
- Declarative infrastructure and operating systems
- Multi-node from day one
- Clear separation of responsibilities
- Safe data handling (ZFS, snapshots, backups)
- Explicit placement (no implicit schedulers)
- Future-proof for Incus clustering and storage evolution

### Explicit non-goals
- Kubernetes
- Auto-scheduling
- Centralized secret managers
- Host-level application workloads

---

## 2. High-level architecture

```
┌──────────────────────────────┐
│ Git monorepo (single source) │
└──────────────┬───────────────┘
               │
┌──────────────▼───────────────┐
│ NixOS physical hosts (nodes) │
│ - Incus daemon               │
│ - ZFS                        │
│ - node_exporter              │
│ - promtail                   │
└──────────────┬───────────────┘
               │
┌──────────────▼───────────────┐
│ Incus cluster (control plane)│
│ - Raft-based                 │
│ - Explicit placement         │
│ - No scheduler               │
└──────────────┬───────────────┘
               │
┌──────────────▼───────────────┐
│ NixOS VMs (guests)           │
│ - Docker / OCI workloads     │
│ - VM-generated age keys      │
│ - ZFS-backed volumes         │
└──────────────┬───────────────┘
               │
┌──────────────▼───────────────┐
│ Service containers           │
│ - Stateless                  │
│ - Explicit volume mounts     │
└──────────────────────────────┘
```

---

## 3. Monorepo layout (Option A – finalized)

```
homelab/
├── flake.nix
├── flake.lock
├── deploy.nix
│
├── host/
│   ├── common/
│   │   ├── base.nix
│   │   ├── incus.nix
│   │   ├── storage.nix
│   │   └── monitoring.nix
│   │
│   └── nodes/
│       ├── elitedesk-1/
│       │   ├── configuration.nix
│       │   └── hardware-configuration.nix
│       ├── elitedesk-2/
│       └── nuc-1/
│
├── infra/
│   └── incus/
│       ├── elitedesk-1/
│       ├── elitedesk-2/
│       └── nuc-1/
│
├── guests/
│   ├── common.nix
│   ├── edge-vm/
│   ├── metrics-vm/
│   └── home-vm/
│
├── services/
│   ├── edge/
│   ├── metrics/
│   └── home/
│
├── secrets/
│   ├── sops.yaml
│   ├── edge.enc.yaml
│   ├── metrics.enc.yaml
│   └── home.enc.yaml
│
└── scripts/
```

---

## 4. Responsibility boundaries (strict)

### Physical host (NixOS, `host/`)
**Allowed**
- Incus daemon
- ZFS pools
- Networking and firewall
- node_exporter
- promtail
- SSH, users, time, hardware management

**Explicitly forbidden**
- Application containers
- Databases
- Reverse proxies
- Stateful services

> Non-trivial: the host must remain **boring, minimal, and replaceable**.  
> Observability agents are allowed because they describe the host itself.

---

### Incus cluster
- Distributed control plane (Raft)
- Unified API endpoint
- Explicit instance placement
- No workload scheduler
- No implicit migrations

---

### Guests (VMs)
- NixOS
- Docker / Podman
- SOPS-managed secrets
- All application state
- All long-lived secrets

---

### Containers
- Stateless
- Configuration via bind mounts
- Data via explicit volumes only

---

## 5. Incus clustering model

### Enabled from day one
- Cluster bootstrapped once
- All nodes join the same cluster
- Same Incus version on all nodes

### Non-trivial constraints
- Stable hostnames are required
- Cluster formation is a one-time imperative action
- After bootstrap, everything returns to declarative management

### Storage in cluster
- Local ZFS pools per node
- Identical pool name on every node (e.g. `zpool`)
- No shared storage required initially

---

## 6. Storage and data model

### ZFS (host level)
- One pool per node
- One dataset per service
- Incus custom storage volumes map to ZFS datasets

### Snapshotting
- Declarative via Incus config:
  - `snapshots.schedule`
  - `snapshots.expiry`
- Applied to:
  - Instances
  - Storage volumes

### Backups
- ZFS send/receive for local or secondary-node backups
- Optional restic for off-site backups
- Snapshots are not backups

---

## 7. Secrets model (SOPS + age)

### Root principle
Secrets never leave the VM trust boundary.

### Implementation
- Each VM generates its own age key on first boot
- Private key exists only inside the VM
- Public key is committed to `secrets/sops.yaml`
- Secrets are encrypted per-VM

### Key lifecycle
- Age private keys are not backed up
- VM recreation generates a new key
- Secrets are re-encrypted when VM identity changes

> Non-trivial: age keys represent **machine identity**, not data.

---

## 8. Provisioning and lifecycle

### Physical hosts
- Installed with NixOS
- Managed via deploy-rs
- Fully declarative
- Reinstall equals reapply configuration

### Incus resources
- Managed via Terraform
- One Terraform state per host or per cluster endpoint
- Explicit `target` for clustered instances

### Guests
- First boot via minimal cloud-init
- Subsequent updates via deploy-rs
- No manual SSH required for normal operation

---

## 9. Update and operations flow

### Infrastructure changes

```bash
terraform apply
```

### OS changes (host or VM)

```bash
deploy-rs
```


### Service changes

```bash
git commit
deploy-rs
```


### Safe upgrade procedure
1. Create Incus snapshot
2. Deploy OS changes
3. Update containers
4. Roll back if needed

---

## 10. Monitoring boundary

- Hosts expose metrics and logs
- Prometheus and Loki run inside guests
- Guests scrape or pull from hosts
- No credentials are pushed downward

---

## 11. Failure and recovery model

### Host failure
- Reinstall NixOS
- Restore ZFS pool
- Rejoin Incus cluster
- Guests reappear

### VM failure
- Recreate VM
- Reattach volumes
- Re-encrypt secrets
- Resume services

---

## 12. Explicit non-goals

- No auto-scheduling
- No shared secrets
- No host-level apps
- No implicit migrations
- No hypervisor-managed backups of application state

---

## 13. Primary sources

### Incus (official)
- Clustering overview  
  https://linuxcontainers.org/incus/docs/main/explanation/clustering/
- Cluster formation  
  https://linuxcontainers.org/incus/docs/main/howto/cluster_form/
- Instance placement and limitations  
  https://linuxcontainers.org/incus/docs/main/explanation/clustering/#instance-placement
- Storage and clustering  
  https://linuxcontainers.org/incus/docs/main/explanation/storage/
- Snapshots and backups  
  https://linuxcontainers.org/incus/docs/main/howto/instances_backup/  
  https://linuxcontainers.org/incus/docs/main/howto/storage_backup_volume/

### Terraform
- Incus provider documentation  
  https://registry.terraform.io/providers/lxc/incus/latest/docs
- Cluster target support  
  https://registry.terraform.io/providers/lxc/incus/latest/docs/resources/instance

### NixOS
- NixOS manual  
  https://nixos.org/manual/nixos/stable/
- Incus on NixOS  
  https://wiki.nixos.org/wiki/Incus
- Prometheus exporters on NixOS  
  https://wiki.nixos.org/wiki/Prometheus
- ZFS on NixOS discussions  
  https://discourse.nixos.org/t/what-is-the-way-to-mount-zfs-filesystems/41005

### Community discussions
- Declarative Incus clustering  
  https://discuss.linuxcontainers.org/t/incus-cluster-preseed/19687
- NixOS as a hypervisor host (Reddit)  
  https://www.reddit.com/r/NixOS/comments/1cvlpul/what_are_your_tools_for_monitoring_your_nixos/

---

## Final note

This architecture is intentionally conservative:
- Explicit over automatic
- Declarative over clever
- Recoverable over convenient

It is suitable as a long-term baseline and a safe starting point for future extensions, automation, or tooling layers.

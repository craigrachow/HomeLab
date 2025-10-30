# HomeLab — Asset Register & Architecture

This document is a single-source reference for my HomeLab running on a dedicated Proxmox host. It is written in a direct, first-person style to help me build, operate and troubleshoot the environment.

---

## Summary

My homelab runs on a single dedicated server with Proxmox as the hypervisor. IP addresses are on a private network (192.168.0.0/24). Proxmox host IP: **192.168.0.200**. Guest VMs will start at **192.168.0.205** and increment upward.

Not all VMs will run at the same time — I will turn on what I need. VM hostnames follow the convention: `HL-<ShortRoleName>` (example: `HL-RHServer`).

Hardware baseline (host):

- CPU: Intel i7 (model-specific cores/threads to be documented in the change log)
- RAM: 16 GB
- Disk: 512 GB SSD
- Hypervisor: Proxmox VE
- Management network: 192.168.0.0/24

---

## Naming Convention

- Proxmox host: `HL-PROXMOX` (IP: 192.168.0.200)
- VM / Container: `HL-<Role>` (example: `HL-RHServer`, `HL-DockHost`)
- Template images: `TEMPLATE-<OS>-YYYYMMDD`

Keep names short but descriptive. This helps when scanning processes, logs and Ansible inventories.

---

## IP Addressing Plan

- Gateway/router (home router): 192.168.0.1
- Proxmox host: 192.168.0.200
- Reserved pool for infrastructure services: 192.168.0.201 - 192.168.0.204
- VM starts: 192.168.0.205 -> upwards (assign sequentially per VM below)

Example static assignments suggested:

- HL-PROXMOX — 192.168.0.200 (Proxmox host)
- HL-RHServer — 192.168.0.205 (Red Hat server — Ansible control, NFS/Samba)
- HL-DOCKER — 192.168.0.206 (Docker host)
- HL-MEDIA — 192.168.0.207 (Jellyfin/media test)
- HL-PWNBOX — 192.168.0.208 (CTF hacking box)
- HL-VULBOX — 192.168.0.209 (Vulnerable app VM)
- HL-SANDWIN — 192.168.0.210 (Windows sandpit)
- HL-SANDLIN — 192.168.0.211 (Linux sandpit)

Document any IP changes in the change-log section.

---

## Asset Register

| Asset ID | Hostname | Role / Purpose | IP Address | CPU | RAM | Disk | OS | Services | Notes |
|---|---:|---|---:|---:|---:|---:|---|---|---|
| A001 | HL-PROXMOX | Hypervisor / Management | 192.168.0.200 | Intel i7 (host) | 16 GB | 512 GB SSD | Proxmox VE | VM hosting, backups | Host machine — primary asset |
| A002 | HL-RHServer | RedHat: Ansible, NFS/SMB | 192.168.0.205 | 2 vCPU | 2–4 GB | 40 GB | RHEL/CentOS/Alma | Ansible, NFS, Samba, SSH | Use for config management, shared storage |
| A003 | HL-DOCKER | Docker host | 192.168.0.206 | 2 vCPU | 2–4 GB | 40–60 GB | Debian/Ubuntu | Docker Engine, Portainer (optional) | Run small apps, containers |
| A004 | HL-MEDIA | Media test | 192.168.0.207 | 2 vCPU | 3–4 GB | 80–120 GB | Debian/Ubuntu | Jellyfin, Samba/NFS | Media transcode testing (may require more disk) |
| A005 | HL-PWNBOX | Pentest / CTF box | 192.168.0.208 | 2 vCPU | 2–4 GB | 40 GB | Kali/Parrot | Pentesting tools, VPN | Keep off internet when not needed; snapshot before use |
| A006 | HL-VULBOX | Vulnerable services | 192.168.0.209 | 2 vCPU | 2–4 GB | 40–80 GB | Debian/Ubuntu | Juice Shop, DVWA, misconfig apps | Isolate from other VMs, snapshot frequently |
| A007 | HL-SANDWIN | Windows sandpit | 192.168.0.210 | 2 vCPU | 4 GB | 60 GB | Windows 10/11 | Testing miscellaneous Windows apps | Use checkpoints, revert after tests |
| A008 | HL-SANDLIN | Linux sandpit | 192.168.0.211 | 2 vCPU | 2–4 GB | 40 GB | Ubuntu/CentOS | Random tests | Template-based deployment |

> Notes:
> - CPU/RAM allocations above are suggestions. I will tune based on actual usage. If running media transcoding (Jellyfin), increase vCPU and RAM for HL-MEDIA.
> - Use thin provisioning on Proxmox to maximise disk usage, but monitor free space closely.

---

## Logical Architecture (textual diagram)

Proxmox host (HL-PROXMOX, 192.168.0.200)
├─ bridged network `vmbr0` -> 192.168.0.0/24 -> home router
├─ VM: HL-RHServer (192.168.0.205)
├─ VM: HL-DOCKER (192.168.0.206)
├─ VM: HL-MEDIA (192.168.0.207)
├─ VM: HL-PWNBOX (192.168.0.208)
├─ VM: HL-VULBOX (192.168.0.209)
├─ VM: HL-SANDWIN (192.168.0.210)
└─ VM: HL-SANDLIN (192.168.0.211)

I will keep traffic on the same L2 network. For extra isolation, I may create VLANs and additional bridges (see Security & Network section).

---

## Network & Isolation

Minimal start:

- All VMs on `vmbr0` (bridge to physical NIC) in 192.168.0.0/24.
- Use static IPs for servers I want predictable access to (Ansible, Docker host, Media).

Recommended hardening / segmentation (optional):

- Create VLANs or separate Linux bridges for categories:
  - `bridge-int` — Infrastructure (HL-RHServer, HL-DOCKER)
  - `bridge-media` — Media servers
  - `bridge-untrusted` — PwnBox, VulBox (restricted internet access)
- Apply firewall rules per bridge using Proxmox firewall or a VM-based firewall.
- When running vulnerable systems (HL-VULBOX), restrict access to only the management subnet and specific ports.

Port forwarding / Internet access:

- If external access needed (Jellyfin mobile streaming, Docker app), set up port forwarding on home router to the Proxmox host or to the specific VM IP depending on NAT rules.
- Prefer using a reverse proxy (Traefik / Nginx Proxy Manager) inside HL-DOCKER for multiple services.

---

## Storage & Backups

Storage layout on Proxmox host (recommended):

- OS/Proxmox on SSD root
- VM disks on local-lvm or ZFS (if I reformat and dedicate disk)
- Consider an external NAS later for larger media storage and off-host backups

Backup strategy:

- Use Proxmox builtin backups (use vzdump) for periodic full backups of VMs.
- Schedule daily or weekly backups depending on VM importance. Example:
  - HL-RHServer: daily (critical config)
  - HL-DOCKER: weekly + images stored in repository
  - HL-MEDIA: weekly (media library rarely changes)
  - HL-VULBOX / PWNBOX: snapshot before/after exercises only
- Keep 2–4 retention points locally. If possible, copy critical backups off-site (external drive or cloud).

Snapshot policy:

- Before performing risky changes (upgrades, tests on sandpit), take a snapshot.
- For vulnerable boxes, revert to clean snapshot after each session.

---

## Services and Roles (details)

### HL-RHServer (A002)
- Role: Ansible control node, NFS/Samba shares for media and test files.
- Services: `ansible`, `sshd`, `nfs-server`, `smbd`.
- Key config: /etc/ansible/hosts (inventory), export shares for `HL-MEDIA` and `HL-DOCKER` if needed.
- Backup: config files and inventory daily.

### HL-DOCKER (A003)
- Role: host small containers and reverse proxy.
- Services: `docker`, `docker-compose`, `portainer` (optional), `nginx` or `traefik`.
- Key config: map volumes to Proxmox storage location; use compose files stored on NFS/Samba share or local template.

### HL-MEDIA (A004)
- Role: Jellyfin and media streaming tests.
- Services: `jellyfin`, Samba/NFS for media shares.
- Note: Media transcoding is CPU heavy — increase vCPU and RAM when actively streaming.

### HL-PWNBOX & HL-VULBOX (A005/A006)
- Role: offensive security testing and intentionally vulnerable apps.
- Isolation: ideally on `bridge-untrusted` with firewall rules blocking lateral movement.
- Maintain snapshots and revert after each session.

### HL-SANDWIN / HL-SANDLIN (A007/A008)
- Role: experimental test VMs for software or config testing.
- Use templates so I can destroy and recreate quickly.

---

## Templates & Automation

- Create VM templates for base images:
  - `TEMPLATE-UBUNTU-YYYYMMDD`
  - `TEMPLATE-WIN10-YYYYMMDD`
  - `TEMPLATE-RHEL-YYYYMMDD`

- Use Ansible from HL-RHServer to manage provisioning and config.
- Keep an `ansible-playbooks` repo (store in git, local or remote) and tag playbooks for each role (docker, media, hardening).

Example basic inventory snippet (Ansible `hosts` file):

```
[proxmox]
192.168.0.200

[linux_servers]
HL-RHServer ansible_host=192.168.0.205
HL-DOCKER ansible_host=192.168.0.206
HL-MEDIA ansible_host=192.168.0.207
HL-SANDLIN ansible_host=192.168.0.211

[windows]
HL-SANDWIN ansible_host=192.168.0.210
```

---

## Security & Hardening

- Keep Proxmox and VM OSes patched. I will run updates regularly but snapshot before major upgrades.
- Disable unnecessary services on each VM.
- Use SSH keys for management; disable password login where possible.
- Use Proxmox firewall and/or VM-level firewalls (ufw/iptables/Windows Defender rules) to segment traffic.
- For HL-PWNBOX and HL-VULBOX: never allow them to initiate connections to other internal guests — only to the internet if needed. Implement explicit deny rules.
- Backup SSH keys and `ansible` vault securely (password manager).

---

## Monitoring & Logging

- Basic checks:
  - Proxmox web UI for resource usage
  - Use `htop`, `glances` inside VMs when troubleshooting
- Optional: run a small monitoring stack in Docker (Prometheus + Grafana or Netdata) on HL-DOCKER for resource metrics.
- Centralise logs for important VMs (rotate logs) or use a simple syslog receiver on HL-RHServer.

---

## Troubleshooting Checklist

1. VM unreachable:
   - Confirm VM running in Proxmox UI.
   - Check assigned IP in Proxmox console.
   - Ping gateway (192.168.0.1) from Proxmox host.
   - From Proxmox shell, `ping 192.168.0.205` (VM IP). If not, check `vmbr0` configuration and firewall.

2. Service failing inside VM:
   - SSH into VM (or open Proxmox console).
   - Check service status (`systemctl status <service>`).
   - Review logs (`journalctl -u <service>`).

3. Storage full or disk errors:
   - From Proxmox, check `df -h` and `pvesm status`.
   - If LVM thin pool filling, either increase space or delete old backups/snapshots.

4. Network isolation issue (vulnerable box talking to other VMs):
   - Check bridge/VLAN assignments.
   - Verify Proxmox firewall rules and VM firewall rules.

5. Performance issues:
   - Check CPU/memory in Proxmox UI.
   - Temporarily power off less important VMs.
   - For media transcode, increase vCPU and RAM or offload to host resources.

---

## Maintenance Tasks (regular)

- Weekly: snapshot critical VMs before major configs, check updates available.
- Bi-weekly: Proxmox & VM OS updates (after snapshots)
- Monthly: prune old Proxmox backups, check SSD health (SMART), verify backups restore ability.
- Before experiments: take a named snapshot (eg. `pre-experiment-20251030`) and document the purpose.

---

## Change Log / Decisions

- 2025-10-30: Document created. Proxmox host IP 192.168.0.200. VM start at 192.168.0.205.
- [Add future changes here: date, change, reason, author]

---

## Quick Start Checklist (first time build)

1. Install Proxmox on host. Assign management IP: 192.168.0.200.
2. Create `vmbr0` bridged to physical NIC.
3. Create base templates for Ubuntu, RHEL and Windows.
4. Provision HL-RHServer first; install Ansible and create inventory.
5. Provision HL-DOCKER and set up reverse proxy.
6. Provision HL-MEDIA and mount NFS/Samba share from HL-RHServer.
7. Create snapshots and schedule backups.
8. Configure Proxmox firewall rules and test isolation for HL-VULBOX and HL-PWNBOX.

---

## Appendix — Short Commands & Notes

- Create template from VM in Proxmox: `qm template <vmid>`
- Backup VM: Proxmox GUI or `vzdump <vmid> --compress lzo --storage <storage-id>`
- List VM IPs (guest agent installed): in Proxmox GUI check "IP addresses" or `qm agent <vmid> network-get-interfaces` (if QEMU guest agent present).
- Install QEMU guest agent (Debian/Ubuntu): `apt install qemu-guest-agent` then enable in Proxmox VM options.

---

If you'd like, I can also:
- produce a printable Word or PDF version of this document;
- create a ready-to-use Ansible inventory and a few starter playbooks;
- provide a small example `docker-compose.yml` for Traefik and Jellyfin.

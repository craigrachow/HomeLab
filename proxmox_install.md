# Proxmox VE — Step-by-Step Install Guide

This guide covers installing **Proxmox VE** on your **Intel i7 / 16GB RAM / 512GB SSD** HomeLab machine.  
You already have the ISO file — we’ll walk through booting, installing, configuring networking, and applying best practices.

---

## 🧰 Prerequisites

- Proxmox VE ISO written to a USB (Rufus, balenaEtcher, or `dd`)
- Intel i7 host with 16GB RAM and 512GB SSD
- Keyboard + monitor attached for setup
- Another computer on the same LAN to access the Proxmox web UI
- Router/gateway with subnet `192.168.0.0/24`
- Static management IP: **192.168.0.200**

---

## ⚙️ Before You Begin — Key Decisions

### ZFS vs LVM-Thin
| Option | Pros | Cons |
|--------|------|------|
| **ZFS** | Data integrity, snapshots, checksums | Higher RAM use (~2GB+), single disk = no redundancy |
| **LVM-Thin (default)** | Lightweight, simple, great for single disk | No built-in integrity checks |

**Recommendation:** Use **LVM-Thin** for your single SSD unless you specifically want ZFS features.

### Tips
- Reserve IP `192.168.0.200` on your router to avoid conflicts  
- Enable **SSH key authentication** and disable password logins later  
- Isolate **HL-PWNBOX** and **HL-VULBOX** on a separate bridge or VLAN  
- Use **backups + snapshots** before updates or testing changes  

---

## 🪛 Installation Steps

### 1. Boot the Proxmox Installer
1. Plug in the USB stick with the Proxmox ISO.
2. Boot the system and select **Install Proxmox VE**.
3. Accept the EULA.

### 2. Choose Target Disk and Filesystem
1. Select your **512GB SSD** as the target.  
2. Choose filesystem:
   - **LVM-Thin (Recommended)** for simplicity.
   - **ZFS (RAID0)** if you want snapshot features.

### 3. Set Region, Password & Email
- Region: Select your timezone.  
- Password: Strong root password.  
- Email: Used for Proxmox alerts.

### 4. Configure Network
| Setting | Value |
|----------|--------|
| Management IP | `192.168.0.200` |
| Netmask | `255.255.255.0` |
| Gateway | `192.168.0.1` |
| DNS | `1.1.1.1` or your router |

### 5. Finish Installation
- Let installation complete.
- Reboot when prompted and remove the USB.

---

## 🌐 Accessing the Proxmox Web UI

1. On another computer, open your browser and visit:  
   **`https://192.168.0.200:8006`**
2. Accept the certificate warning.  
3. Log in with:
   - User: `root`
   - Password: (the one you set)

If the page doesn’t load, check the IP using the host console:
```bash
ip addr
```

---

## 🧩 Post-Install Setup

### 1. Update Packages
```bash
apt update && apt full-upgrade -y
```

If you’re using the free (no-subscription) version, add the non-subscription repo:
```bash
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
apt update
```

### 2. Configure SSH Keys
On your workstation:
```bash
ssh-keygen
ssh-copy-id root@192.168.0.200
```
Then optionally disable password logins:
```bash
nano /etc/ssh/sshd_config
# Set the following:
PermitRootLogin prohibit-password
PasswordAuthentication no
systemctl reload sshd
```

### 3. Configure NTP (Time Sync)
```bash
timedatectl set-ntp true
```

### 4. Verify Network Bridge
Check `/etc/network/interfaces`:
```text
auto lo
iface lo inet loopback

auto vmbr0
iface vmbr0 inet static
    address 192.168.0.200/24
    gateway 192.168.0.1
    bridge-ports enp3s0
    bridge-stp off
    bridge-fd 0
```
Replace `enp3s0` with your network interface name (`ip link` to find it).

---

## 🗂️ Storage Setup

- **LVM-Thin:** Already created during install, good for VM disks.  
- **ZFS:** Create separate datasets for media or VM images.  
- **Extra storage:** Add CIFS/NFS for media or backups:  
  GUI → Datacenter → Storage → Add → (choose type)

---

## 🧠 Useful Proxmox Commands

| Command | Description |
|----------|--------------|
| `pveversion -v` | Show Proxmox version |
| `pvesm status` | View storage volumes |
| `qm list` | List virtual machines |
| `vzdump <vmid>` | Manual VM backup |
| `pveproxy restart` | Restart web interface |
| `systemctl restart networking` | Restart network services |

---

## 🖥️ Creating Your First VMs

1. Upload ISOs to **local** storage via web UI.  
2. Create a VM:
   - HL-RHServer (Ansible + NFS)
   - HL-DOCKER (Docker host)
   - HL-MEDIA (Jellyfin test)
   - HL-PWNBOX (offensive testing)
   - HL-VULBOX (vulnerable apps)
   - HL-SANDPIT (Windows or Linux testbed)
3. Install **QEMU Guest Agent** inside each VM:
```bash
apt install qemu-guest-agent -y
systemctl enable --now qemu-guest-agent
```

---

## 🧰 Backups & Snapshots

| Task | Recommendation |
|-------|----------------|
| Critical VMs (HL-RHServer) | Daily backups |
| General VMs | Weekly backups |
| Vuln/CTF Boxes | Snapshots only before tests |
| Retention | 2–4 copies minimum |

> You can configure automated backups in:  
> **Datacenter → Backup → Add**

---

## 🔒 Security & Hardening

- Use SSH keys only — disable password auth.  
- Keep untrusted boxes (HL-PWNBOX, HL-VULBOX) isolated on separate bridge or VLAN.  
- Enable Proxmox firewall at both **Datacenter** and **Node** level.  
- Regularly update Proxmox and guest OSs.  
- Use snapshots before upgrades or risky changes.  
- Set alerts to your email (Datacenter → Notifications).

---

## 🧱 Best Practices

- Allocate resources efficiently:  
  - 2 vCPUs / 4GB RAM for general VMs  
  - 4 vCPUs / 8GB RAM for Jellyfin when streaming  
- Keep host updates before guest updates.  
- Store ISOs, templates, and backups in organized directories.  
- Use **Ansible** from HL-RHServer for configuration management.  
- Maintain a markdown **change log** for all VM and network edits.

---

## 🚦 Troubleshooting

| Issue | Solution |
|--------|-----------|
| Can't access web UI | Check IP, ensure port 8006 open |
| SSH fails | Verify authorized_keys and sshd_config |
| Disk space full | Prune backups/snapshots: `vzdump --prune-backups keep-last=3` |
| VM not on LAN | Check bridge mapping and interface |

---

## ✅ Quick Build Checklist

- [ ] Install Proxmox and set IP `192.168.0.200`
- [ ] Update & patch host
- [ ] Set up SSH key login
- [ ] Add LVM-thin or ZFS storage
- [ ] Upload OS ISOs
- [ ] Create VMs and install guest agent
- [ ] Enable backups
- [ ] Configure firewall
- [ ] Snapshot before major changes

---

## 🧾 Final Notes

- 16GB RAM is plenty for lightweight testing; limit VM memory and overcommit carefully.  
- Use templates to clone new VMs quickly.  
- Take advantage of Proxmox’s snapshot & backup features — they’ll save you hours.  
- If something breaks, restore from snapshot, not from scratch.

---

If you want, I can also write a Markdown guide for provisioning your first VMs (HL-RHServer, HL-DOCKER, HL-MEDIA) with Ansible and Docker.

# Proxmox VE — Step-by-Step Install Guide

This guide covers how i went about installing **Proxmox VE** on my HomeLab machine.  

---

## 🧰 Prerequisites

- Proxmox VE ISO written to a USB (Rufus, balenaEtcher, or `dd`)
- Keyboard + monitor attached for setup
- Another computer on the same LAN to access the Proxmox web UI
- Router/gateway with subnet `192.168.0.0/24`
- Static management IP: **192.168.0.200**

---

## 🪛 Installation Steps

### 1. Boot the Proxmox Installer
1. Plug in the USB stick with the Proxmox ISO.
2. Boot the system and select **Install Proxmox VE**.
3. Accept the EULA.

### 2. Choose Target Disk and Filesystem
1. Select nessesary disk as the target.  
2. Choose filesystem:
   - **LVM-Thin (Recommended)** for simplicity.

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

---

## 🧩 Post-Install Setup

### 1. Disable No-Subscription Annoyances 
1. In webUI navigate to Repositories 
2. Disable Enterprise Repository 
3. Add Non-Subscription Repository
4. (Optional) Remove the “No Valid Subscription” Popup:
```bash
sed -i.bak "s/data.status !== 'Active'/false/" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
systemctl restart pveproxy.service
```

### 2. Update Packages
```bash
apt update && apt full-upgrade -y
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

- **Local-LVM (LVM-Thin):** Already created during install, good for VM disks.  
- **Local (ZFS):** Created separate datasets for media or VM images.  
- **Extra storage:** Add CIFS/NFS for media or backups:
### ⚙️ Step 1. Create a Dedicated Storage Dataset
1. Log in to **TrueNAS SCALE Web UI**.
2. Go to **Storage → Datasets → Add Dataset**.
3. Create a dataset called `homelab`.
   - **Share Type:** Generic  
   - **Compression:** lz4  
   - **ACL Type:** POSIX  
4. Click **Save**.
5. Create a Dedicated User for Proxmox Access:
6. Go to **Accounts → Users → Add User**.
Set:
   - **Username:** `proxmox`
   - **Password:** (strong password)
   - **Shell:** `/usr/sbin/nologin`
   - Under **Auxiliary Groups**, add `wheel` or `backup` if applicable.  
Click **Save**.
7. Set Dataset Permissions
8. Go to your dataset: **Storage → Datasets → homelab → Edit Permissions**.
Set:  
   - **Owner (User):** `proxmox`
   - **Owner (Group):** `proxmox`
   - **Permissions:** Read/Write/Execute for owner  
Tick apply user and apply group. Click **Save changes**.
9. Enable and Configure NFS Service:
10. Navigate to **Shares → Unix Shares (NFS) → Add**.
11. Choose the path:  
   `/mnt/<poolname>/homelab`
Check:  
   - ✅ **Mapall User:** `proxmox`
   - ✅ **Mapall Group:** `proxmoxuser`
12. Click **Save**, then **Enable Service**.
### Step 2 on Proxmox, mount it using CIFS/SMB:
```bash
mkdir -p /mnt/homelab
mount -t cifs //192.168.0.150/homelab /mnt/homelab \
  -o username=proxmox,password='YOUR_PASSWORD',vers=3.0
```
1. To make it permanent, edit /etc/fstab on Proxmox and add the following line:  
//192.168.0.150/homelab /mnt/homelab cifs credentials=/root/.smbcred,iocharset=utf8,vers=3.0 0 0
To test type **mount -a**
2. Create /root/.smbcred:  
username=proxmox
password=YOUR_PASSWORD
3. Set permissions:  
chmod 600 /root/.smbcred
### Step 3. Add Storage to Proxmox
In the Proxmox Web UI:
1. Go to Datacenter → Storage → Add → NFS (or CIFS).
- Name: truenas-homelab
- Server: 192.168.0.150
- Username: proxmox
- Password: YOUR_PASSWORD
- Share: homelab (/mnt/homelab)
- Content types:backup, ISO image, Disk image
Click Add.  
### Step 4. Test Backup & Upload
Test from CLI:
vzdump 100 --dumpdir /mnt/homelab --mode snapshot
Or upload an ISO via the Proxmox web interface.


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

# HL-SANDLIN — Ubuntu Server Build Guide

This document details the build and configuration process for **HL-SANDLIN**, an Ubuntu Server VM deployed in **Proxmox VE** within the HomeLab environment.

---

## 🧰 Overview

| Parameter | Value |
|------------|--------|
| **VM Name** | HL-SANDLIN |
| **Role** | General-purpose sandbox Linux VM |
| **Proxmox Host** | 192.168.0.200 |
| **VM IP** | 192.168.0.211 |
| **Operating System** | Ubuntu Server 24.04 LTS (Recommended) |
| **Purpose** | Base template for cloning new Ubuntu-based VMs |
| **State** | Always powered off (template) |

---

## ⚙️ VM Configuration (Proxmox)

1. **Upload Ubuntu ISO**
   - Upload your Ubuntu Server ISO (`ubuntu-24.04-live-server-amd64.iso`) to the **local ISO storage** in Proxmox.

2. **Create the VM**
   - In the Proxmox Web UI: `Create VM`
     - **Node:** Select your Proxmox host
     - **VM ID:** Auto-generated
     - **Name:** `HL-SANDLIN`
     - **ISO Image:** Select uploaded Ubuntu Server ISO
     - **System:** Default (BIOS SeaBIOS or UEFI if preferred)
     - **Machine Type:** `q35`
     - **Disk:** 32GB (LVM-Thin)
     - **CPU:** 2 cores
     - **Memory:** 4GB (4096MB)
     - **Network:** Bridge to `vmbr0`

3. **Install Ubuntu Server**
   - Boot VM → Install Ubuntu Server (Minimal installation)
   - When prompted:
     - **Hostname:** `hl-sandlin`
     - **Username:** `craig` (or preferred admin)
     - **Password:** Strong local password
     - **Static IP Configuration:**
       ```
       Address: 192.168.0.211
       Netmask: 255.255.255.0
       Gateway: 192.168.0.1
       DNS: 1.1.1.1, 8.8.8.8
       ```
     - **SSH Server:** Enable **"Install OpenSSH server"**
     - **Software selection:** Standard utilities only

---

## 🔧 Post-Install Configuration

Once the installation completes, log into the Proxmox console or via SSH from another device.

### 1. Update & Upgrade System
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Verify Network
```bash
ip a
ping 8.8.8.8
hostname -I
```

Expected output includes `192.168.0.211`.

### 3. Install QEMU Guest Agent
```bash
sudo apt install qemu-guest-agent -y
sudo systemctl enable --now qemu-guest-agent
```

### 4. Configure SSH (Hardened Access)

#### Allow SSH Key Authentication
On your local machine:
```bash
ssh-keygen
ssh-copy-id craig@192.168.0.211
```

#### Disable Password Authentication
```bash
sudo nano /etc/ssh/sshd_config
# Update or add the following:
PermitRootLogin prohibit-password
PasswordAuthentication no

sudo systemctl restart ssh
```

#### Test SSH Access
From your workstation:
```bash
ssh craig@192.168.0.211
```

---

## 🧩 System Preparation for Cloning

Before converting HL-SANDLIN into a template:

### 1. Clean the Machine
```bash
sudo apt autoremove -y
sudo apt clean
sudo cloud-init clean
sudo rm -rf /tmp/*
history -c
```

### 2. Reset Host Identity
```bash
sudo rm -f /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
```

### 3. Clear Machine ID
```bash
sudo truncate -s 0 /etc/machine-id
sudo rm /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id
```

### 4. Power Off
```bash
sudo shutdown now
```

---

## 🧱 Convert to Proxmox Template

1. In **Proxmox Web UI:**
   - Right-click the VM → **Convert to Template**

2. When cloning a new VM:
   - Use **Linked Clone** for fast lightweight copies.
   - Update hostname and IP in `/etc/hostname` and `/etc/netplan/*.yaml`.

Example:
```bash
sudo hostnamectl set-hostname newhostname
sudo nano /etc/netplan/01-netcfg.yaml
sudo netplan apply
```

---

## 🧠 Recommended Post-Clone Tasks

| Task | Command / Notes |
|------|------------------|
| Update system | `sudo apt update && sudo apt upgrade -y` |
| Install Docker (if required) | `curl -fsSL https://get.docker.com | sh` |
| Install Python/Ansible | `sudo apt install python3 ansible -y` |
| Set unique hostname | `sudo hostnamectl set-hostname <newname>` |
| Verify guest agent status | `systemctl status qemu-guest-agent` |

---

## 🔒 Security & Best Practices

- Use **SSH key-based authentication only**.
- Keep base image minimal — add software post-clone.
- Perform updates only on new clones (not template).
- Maintain a **snapshot of HL-SANDLIN** post-cleanup for recovery.
- Verify template boots cleanly before using in automation.

---

## ✅ Quick Build Checklist

- [ ] Create new VM HL-SANDLIN (Ubuntu Server)
- [ ] Assign static IP `192.168.0.211`
- [ ] Enable SSH and install guest agent
- [ ] Harden SSH config
- [ ] Clean OS and reset host identity
- [ ] Convert VM to Proxmox template
- [ ] Snapshot completed template

---

## 🧾 Notes

- The HL-SANDLIN template forms the base for all Ubuntu-based sandbox or utility VMs.
- For testing environments, use **Linked Clones** to save storage.
- If you plan to automate deployment, integrate HL-SANDLIN into **Ansible inventory**.

---

**Document Owner:** Craig Rachow  
**Environment:** HomeLab (Proxmox 8.x)  
**Last Updated:** 2025-10-31

# HL-RHServer Red Hat Enterprise Linux 10 Build Guide

## 1. Overview
This document outlines the build instructions for deploying a **Red Hat Enterprise Linux (RHEL) 10** virtual machine named **HL-RHServer** on a Proxmox Virtual Environment.  
The final server configuration will include:
- Static IP: **192.168.0.205**
- SSH enabled  
- Configured as an **Ansible control node**
- Configured as an **NFS** and **SMB** server  
- Additional recommended hardening and configuration steps

---

## 2. VM Specifications (Recommended)
| Setting | Value |
|--------|--------|
| Name | HL-RHServer |
| CPU | 2 vCPUs (`Select host CPU type`) |
| RAM | 4 GB |
| Storage | 30 GB |
| Network | VirtIO |
| OS Type | Linux / RHEL |

---

## 3. Install RHEL 10
1. Upload the RHEL ISO to Proxmox (`local -> ISO Images`).
2. Create a new VM:
   - Select uploaded RHEL ISO  
   - BIOS: **OVMF (UEFI)** recommended  
   - Disk: VirtIO SCSI  
3. Boot into the RHEL installer.
4. Select:
   - **Server with GUI** *or* **Minimal Install** (recommended for infrastructure nodes)
   - Enable **Kdump**
   - Configure timezone (Australia/Darwin recommended for local use)
5. Set the root password and create an admin user (example: `admin`).

---

## 4. Set Static IP (192.168.0.205)
Edit your network connection:

```bash
nmcli connection show
nmcli connection modify <name> ipv4.addresses 192.168.0.205/24
nmcli connection modify <name> ipv4.gateway 192.168.0.1
nmcli connection modify <name> ipv4.dns "1.1.1.1 8.8.8.8"
nmcli connection modify <name> ipv4.method manual
nmcli connection up <name>
```

---

## 5. Enable SSH
SSH is normally installed by default. Enable and start it:

```bash
sudo systemctl enable sshd
sudo systemctl start sshd
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```

---

## 6. Prepare for Ansible
Install required packages:

```bash
sudo dnf install -y python3 python3-pip ansible-core git
```

Enable passwordless sudo for the Ansible admin user:

```bash
sudo visudo
```

Add:

```
admin ALL=(ALL) NOPASSWD: ALL
```

---

## 7. Configure as an NFS Server
Install NFS utilities:

```bash
sudo dnf install -y nfs-utils
```

Create NFS share directory:

```bash
sudo mkdir -p /srv/nfs/proxmox_backups
sudo chown -R nobody:nobody /srv/nfs/proxmox_backups
```

Edit `/etc/exports`:

```
/srv/nfs/proxmox_backups 192.168.0.0/24(rw,sync,no_root_squash,no_subtree_check)
```

Apply settings:

```bash
sudo exportfs -arv
sudo systemctl enable --now nfs-server
```

---

## 8. Configure as an SMB (Samba) Server
Install samba:

```bash
sudo dnf install -y samba samba-common samba-client
```

Create share directory:

```bash
sudo mkdir -p /srv/smb/share
sudo chmod -R 777 /srv/smb/share
```

Add Samba config:

```bash
sudo bash -c 'cat >> /etc/samba/smb.conf <<EOF
[proxmox-share]
    path = /srv/smb/share
    browseable = yes
    writable = yes
    guest ok = no
    valid users = admin
EOF'
```

Create Samba user:

```bash
sudo smbpasswd -a admin
```

Enable services:

```bash
sudo systemctl enable --now smb nmb
sudo firewall-cmd --permanent --add-service=samba
sudo firewall-cmd --reload
```

---

## 9. Recommended System Hardening
### Disable root SSH login
```bash
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### Enable automatic updates
```bash
sudo dnf install -y dnf-automatic
sudo systemctl enable --now dnf-automatic.timer
```

### Install fail2ban
```bash
sudo dnf install -y fail2ban
sudo systemctl enable --now fail2ban
```

---

## 10. Snapshot Before Use
When the system is fully configured:

1. Shut down the VM.
2. In Proxmox UI → **Snapshot → Create**.
3. Name: `HL-PROXMOX-BASE-BUILD`.

This gives you a clean rollback point.

---

## 11. Final Verification Checklist
- [ ] Static IP 192.168.0.205 set  
- [ ] SSH accessible  
- [ ] Ansible installed & functioning  
- [ ] NFS share reachable from Proxmox  
- [ ] SMB share reachable from Windows/Linux clients  
- [ ] System hardening applied  
- [ ] Snapshot created  

---

## 12. Completed
Your **HL-PROXMOX** RHEL 10 machine is now ready to serve as an Ansible controller, NFS server, and SMB server inside your Proxmox environment.

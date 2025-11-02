# HL-PWNBOX — Parrot OS Build Guide

**Purpose:**  
This VM serves as a **penetration testing, CTF, and security research** environment within my HomeLab.  
It will run **Parrot OS (HTB Edition)** on the Proxmox platform, isolated from production hosts.

---

## 🖥️ System Overview

| Item | Description |
|------|--------------|
| **VM Name** | `HL-PWNBOX` |
| **Purpose** | Penetration Testing / CTF / Ethical Hacking |
| **Base OS** | Parrot OS HTB Edition (latest stable ISO) |
| **Host Platform** | Proxmox VE |
| **Assigned IP** | `192.168.0.208` |
| **Network Type** | Bridged (vmbr0) |
| **Resources** | 2 vCPU / 8GB RAM / 20GB Disk |
| **Access Methods** | SSH, RDP (XRDP), Proxmox Console |

---

## ⚙️ Step 1. Upload ISO to Proxmox

1. Download Parrot OS Security ISO from the official site.
2. Log in to the **Proxmox Web UI**.
3. Go to **Datacenter → Storage → ISO Images**.
4. Click **Upload** and select your Parrot OS ISO.

---

## 🧱 Step 2. Create the Virtual Machine

1. In Proxmox, click **Create VM**.
2. Set:
   - **Node:** your Proxmox host  
   - **VM ID:** auto or custom  
   - **Name:** `HL-PWNBOX`
3. **OS Tab:**  
   - Choose your uploaded **Parrot ISO**
4. **System Tab:**  
   - BIOS: `Default (SeaBIOS)`    
   - SCSI Controller: `VirtIO SCSI`
5. **Hard Disk:**  
   - Disk Size: `20GB`  
   - Storage: your preferred datastore
6. **CPU:**  
   - Cores: `4`  
   - Type: `host`
7. **Memory:**  
   - Allocate `8192 MB`
8. **Network:**  
   - Bridge: `vmbr0`  
9. Finish setup and start the VM.

---

## 💽 Step 3. Install Parrot OS

1. Open the **Console** in Proxmox and boot the ISO.
2. Choose **Install Parrot OS** (not Live).
3. Follow the installation prompts:
   - Partition disk automatically
   - Create a user account
   - Set hostname: `HL-PWNBOX`
4. Once installation is complete, remove the ISO and reboot.

---

## 🌐 Step 4. Configure Static IP

After logging in:

```bash
sudo nano /etc/network/interfaces
```

Add or modify:

```bash
auto eth0
iface eth0 inet static
  address 192.168.0.208
  netmask 255.255.255.0
  gateway 192.168.0.1
  dns-nameservers 1.1.1.1 8.8.8.8
```

Save and restart networking:

```bash
sudo systemctl restart networking
```

Verify:

```bash
ip addr show eth0
```

---

## 🔐 Step 5. Enable SSH Access

1. Install and enable the SSH service:

```bash
sudo apt update && sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

2. Confirm status:

```bash
sudo systemctl status ssh
```

3. (Optional) Harden SSH:

```bash
sudo nano /etc/ssh/sshd_config
```

Set:
```
PermitRootLogin no
PasswordAuthentication yes
AllowUsers craig
```

Then restart:
```bash
sudo systemctl restart ssh
```

Now you can SSH in:
```bash
ssh craig@192.168.0.208
```

---

## 🖥️ Step 6. Enable Remote Desktop Access (RDP)

1. Install XRDP:
```bash
sudo apt install -y xrdp
```

2. Enable and start service:
```bash
sudo systemctl enable xrdp
sudo systemctl start xrdp
```

3. Allow XRDP through firewall (if active):
```bash
sudo ufw allow 3389/tcp
```

You can now connect via **Windows Remote Desktop (RDP)**:
```
Address: 192.168.0.208
Username: craig
Password: ********
```

---

## 🧰 Step 7. Recommended Post-Install Tools

Install your preferred hacking/CTF tools:

```bash
sudo apt install -y nmap metasploit-framework gobuster john hashcat feroxbuster sqlmap wfuzz
```

Or update Parrot’s security toolset:

```bash
sudo parrot-upgrade
```

---

## 🛡️ Step 8. Optional Security & Snapshot Configuration

1. **Take a clean snapshot** once configured:
   - In Proxmox: `HL-PWNBOX → Snapshots → Take Snapshot`
2. **Enable updates:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
3. **Restrict Proxmox Network Access:**
   - Keep this VM isolated in your **HomeLab subnet** only.
4. **Enable Proxmox Backup:**
   - Add this VM to your `truenas-backups` NFS or SMB share.

---

## 🧪 Step 9. Verify Connectivity

- Ping from Proxmox:
  ```bash
  ping 192.168.0.208
  ```
- SSH test:
  ```bash
  ssh craig@192.168.0.208
  ```
- RDP test using client of your choice.

---

## 🏁 HL-PWNBOX Ready

You now have a fully functional, secure **Parrot OS hacking VM** ready for CTFs, penetration testing, and HomeLab experimentation.

**Backup:** Add this VM to your Proxmox backup schedule.  
**Snapshot regularly** before major tool or system updates.

---

**Document Owner:** Craig Rachow
**Environment:** HomeLab (Proxmox 8.x)
**Last Updated:** 2025-11-02

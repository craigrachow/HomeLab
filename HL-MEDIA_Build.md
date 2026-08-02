# HL-MEDIA Build Guide
## Ubuntu Media Server (Jellyfin)

---

# Document Information

| Item | Value |
|------|-------|
| Hostname | HL-MEDIA |
| Platform | Proxmox VE |
| Operating System | Ubuntu Server 24.04 LTS |
| VM IP Address | 192.168.0.207 |
| Purpose | Home Media Streaming Server |
| Primary Applications | Jellyfin |
| Build Version | 1.0 |
| Last Updated | August 2026 |

---

# Overview

HL-MEDIA is a dedicated media streaming server within the HomeLab environment.

Its primary functions include:

- Hosting Jellyfin
- Streaming Movies
- Streaming TV Shows
- IPTV Support
- Central media library
- Metadata downloads
- Artwork downloads
- User account management
- Family media streaming

Unlike the Docker server, HL-MEDIA has a single purpose.

Keeping it dedicated makes backups, upgrades and troubleshooting much easier.

---

# HomeLab Position

```

Internet
│
Home Router
│
192.168.0.0/24
│
Proxmox
192.168.0.200
│
├──────────────┬───────────────┬──────────────┐
│ │ │ │
HL-PROXMOX HL-DOCKER HL-MEDIA HL-PWNBOX
205 206 207 208

```

---

# Recommended VM Resources

| Resource | Recommended |
|----------|-------------|
| CPU | 4 vCPU |
| RAM | 8 GB |
| Disk | 80 GB OS |
| Additional Disk | 1TB+ Media Storage |
| BIOS | OVMF (UEFI) |
| Machine Type | q35 |
| SCSI Controller | VirtIO SCSI |
| Disk Cache | Write Back |
| SSD Emulation | Enabled |
| Discard | Enabled |
| QEMU Guest Agent | Enabled |

---

# Recommended Storage Layout

Rather than storing media on the operating system disk, create a second virtual disk.

```

Disk 1

80GB

Ubuntu Operating System

Disk 2

1TB+

Media Storage

/mnt/media

```

Benefits

- Easier backups
- Easier VM rebuilds
- Faster snapshots
- Expand storage independently

---

# VM Creation

Create a new VM within Proxmox.

```

Name

HL-MEDIA

```

Guest OS

```

Linux

Kernel 6.x

```

CPU

```

4 Cores

Type Host

```

Memory

```

8192 MB

```

Disk

```

80GB

VirtIO SCSI

SSD Emulation Enabled

Discard Enabled

```

Network

```

Bridge vmbr0

VirtIO

```

Finish the wizard.

Enable

```

QEMU Guest Agent

```

before powering on.

---

# Ubuntu Installation

Install Ubuntu Server 24.04 LTS.

Recommended settings

Hostname

```

HL-MEDIA

```

Install

```

OpenSSH Server

```

during setup.

Complete installation.

Remove ISO.

Reboot.

---

# Update Ubuntu

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo reboot
```

---

# Configure Static Networking

Edit Netplan.

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

Example

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false

      addresses:

        - 192.168.0.207/24

      gateway4: 192.168.0.1

      nameservers:

        addresses:

          - 1.1.1.1

          - 8.8.8.8
```

Apply.

```bash
sudo netplan apply
```

Verify.

```bash
ip addr

ping google.com
```

---

# Install QEMU Guest Agent

```bash
sudo apt install qemu-guest-agent -y

sudo systemctl enable qemu-guest-agent

sudo systemctl start qemu-guest-agent
```

---

# Install SSH

```bash
sudo apt install openssh-server -y

sudo systemctl enable ssh

sudo systemctl start ssh
```

Verify

```bash
systemctl status ssh
```

---

# Install XRDP Remote Desktop

Although Ubuntu Server is intended for command-line administration, a lightweight desktop can make occasional maintenance easier.

Install the XFCE desktop and XRDP:

```bash
sudo apt install -y xfce4 xfce4-goodies xrdp
```

Configure XRDP to use XFCE:

```bash
echo "startxfce4" > ~/.xsession
sudo systemctl enable xrdp
sudo systemctl start xrdp
```

Allow XRDP through the firewall if UFW is enabled:

```bash
sudo ufw allow 3389/tcp
```

Connect from Windows Remote Desktop to:

```

192.168.0.207

```

using your Ubuntu username and password.

---

# Prepare the Media Disk

If using a second virtual disk, identify it:

```bash
lsblk
```

Assuming the disk is `/dev/sdb`:

```bash
sudo parted /dev/sdb --script mklabel gpt
sudo parted /dev/sdb --script mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/sdb1
```

Create a mount point:

```bash
sudo mkdir -p /mnt/media
```

Find the UUID:

```bash
sudo blkid
```

Add it to `/etc/fstab`:

```text
UUID=<YOUR-UUID> /mnt/media ext4 defaults,nofail 0 2
```

Mount it:

```bash
sudo mount -a
df -h
```

---

# Recommended Folder Structure

```text
/mnt/media

├── Movies

├── TV Shows

├── IPTV

├── Music

├── Downloads

├── Metadata

├── Transcoding

└── Backups

```

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

---

# Install Jellyfin

Jellyfin should always be installed from the official Jellyfin repository rather than the Ubuntu repository. This ensures the latest stable version is installed and simplifies future upgrades.

## Install Required Packages

```bash
sudo apt update

sudo apt install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg
```

---

## Add the Official Jellyfin Repository

Import the signing key.

```bash
curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key \
| sudo gpg --dearmor \
-o /usr/share/keyrings/jellyfin.gpg
```

Add the repository.

```bash
echo "deb [signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu noble main" \
| sudo tee /etc/apt/sources.list.d/jellyfin.list
```

Update package lists.

```bash
sudo apt update
```

---

## Install Jellyfin

```bash
sudo apt install jellyfin -y
```

Enable the service.

```bash
sudo systemctl enable jellyfin

sudo systemctl start jellyfin
```

Verify.

```bash
systemctl status jellyfin
```

---

# Jellyfin Web Interface

Browse to

```
http://192.168.0.207:8096
```

Complete the first-time setup wizard.

Recommended administrator account.

```
Username

admin
```

Use a strong password.

---

# Configure Storage

Create the following directories.

```bash
sudo mkdir -p /mnt/media/{Movies,"TV Shows",Music,Downloads,Metadata,Transcoding,IPTV,Backups}
```

Give Jellyfin ownership.

```bash
sudo chown -R jellyfin:jellyfin /mnt/media

sudo chmod -R 775 /mnt/media
```

---

# Create Libraries

Within Jellyfin create libraries.

Movies

```
/mnt/media/Movies
```

TV Shows

```
/mnt/media/TV Shows
```

Music

```
/mnt/media/Music
```

---

# Configure Metadata

Navigate to

```
Dashboard

Libraries

Metadata
```

Enable

- Download artwork
- Download subtitles
- Download cast information
- Download trailers
- Download chapter images

Metadata should be stored with the media where possible.

---

# Configure IPTV

Jellyfin has native IPTV support.

Navigate to

```
Dashboard

Live TV
```

Select

```
Add Tuner
```

Choose

```
M3U Tuner
```

Enter your IPTV playlist URL.

Example

```
http://provider.example.com/playlist.m3u
```

Next

Add your XMLTV Guide.

Example

```
http://provider.example.com/guide.xml
```

After saving, Live TV will populate automatically.

---

# Configure Hardware Transcoding

If your Intel CPU supports Quick Sync.

Install drivers.

```bash
sudo apt install intel-media-va-driver-non-free vainfo -y
```

Verify.

```bash
vainfo
```

Within Jellyfin.

Dashboard

Playback

Transcoding

Enable

```
Intel Quick Sync
```

Hardware transcoding dramatically reduces CPU usage during streaming.

---

# Recommended Playback Settings

Streaming

```
Allow Direct Play

Enabled
```

```
Allow Direct Stream

Enabled
```

```
Fallback Transcoding

Enabled
```

Maximum simultaneous transcodes.

```
2
```

---

# Create Users

Recommended.

| User | Permissions |
|--------|------------|
| admin | Full Administration |
| Family | Standard Access |
| Kids | Restricted Libraries |
| Guest | Optional |

Disable administrator permissions for normal viewing accounts.

---

# Scheduled Library Scan

Enable

```
Scan Library

Every 6 Hours
```

Enable

```
Realtime Monitoring
```

This automatically imports newly downloaded media.

---

# Firewall

If UFW is enabled.

```bash
sudo ufw allow 8096/tcp
```

If HTTPS is configured later.

```bash
sudo ufw allow 8920/tcp
```

---

# Automatic Startup

Verify.

```bash
systemctl is-enabled jellyfin
```

Expected.

```
enabled
```

---

# Backup Strategy

Back up.

```
/etc/jellyfin

/var/lib/jellyfin

/mnt/media
```

The operating system can always be rebuilt.

Your media and Jellyfin configuration are the important assets.

---

# Recommended Plugins

Install from the Jellyfin Plugin Catalogue.

Recommended.

- Intro Skipper
- TMDb Box Sets
- Fanart
- OMDb
- MusicBrainz

Avoid installing unnecessary plugins.

---

# Performance Recommendations

Enable.

```
Hardware Acceleration
```

Store.

```
Metadata

on SSD
```

Store.

```
Media

on Large Storage Disk
```

Use wired Ethernet where possible.

Avoid Wi-Fi for the server.

---

# Verification Checklist

Verify.

```bash
systemctl status jellyfin
```

Browse.

```
http://192.168.0.207:8096
```

Confirm.

- Jellyfin login page loads
- Movies library created
- TV library created
- IPTV channels populate
- Metadata downloads correctly
- Playback works
- Hardware transcoding available
- Server starts automatically after reboot

---

# Future Expansion

HL-MEDIA has been intentionally kept simple.

Future additions could include.

- Sonarr
- Radarr
- Prowlarr
- Bazarr
- qBittorrent
- Overseerr
- Tautulli

These applications should ideally be deployed as Docker containers on **HL-DOCKER** and integrated with Jellyfin, rather than installed directly on HL-MEDIA. This keeps HL-MEDIA focused on media serving while centralising container management on your dedicated Docker host.

---

# Build Complete

HL-MEDIA is now configured as a dedicated media server providing:

- SSH administration
- XRDP remote desktop
- Jellyfin media streaming
- Persistent media storage
- IPTV support
- Automatic metadata downloads
- Hardware transcoding (where supported)
- Automatic startup after reboot
- Structured media library
- Backup-ready storage layout

This configuration follows the same design principles used throughout the HomeLab:

- One VM, one primary purpose
- Persistent storage separated from the operating system
- Simple recovery and rebuild process
- Consistent directory structure
- Easy future expansion

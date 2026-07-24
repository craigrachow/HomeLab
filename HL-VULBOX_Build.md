# HL-VULBOX — Kali Linux Vulnerable Lab Build Guide

See build steps for Kali, static IP **192.168.0.209**, enable SSH and XRDP, install Docker and Docker Compose, deploy OWASP Juice Shop under `/containers/juiceshop`, install Metasploitable3 (or preferably deploy as a separate VM if nested virtualization is unavailable), configure a root cron job `0 */6 * * * /sbin/shutdown -h now`, isolate the VM from the Internet, snapshot before changes, and verify SSH, XRDP, Docker, Juice Shop, and cron configuration.

## Build Checklist
- [ ] Kali installed
- [ ] Static IP configured
- [ ] SSH enabled
- [ ] XRDP enabled
- [ ] Docker installed
- [ ] Docker Compose installed
- [ ] Juice Shop deployed
- [ ] Metasploitable3 available
- [ ] Shutdown cron configured
- [ ] Snapshot created
# HL-VULBOX Build Guide
## Kali Linux Vulnerable Lab

---

# Document Information

| Item | Value |
|------|-------|
| Hostname | HL-VULBOX |
| Platform | Proxmox VE |
| Operating System | Kali Linux (Latest Stable) |
| VM IP Address | 192.168.0.209 |
| Purpose | Vulnerable Testing Platform |
| Primary User | Craig Rachow |
| Build Version | 1.0 |
| Last Updated | July 2026 |

---

# Overview

HL-VULBOX is a deliberately vulnerable virtual machine used for:

- OWASP Top 10 practice
- Capture The Flag (CTF)
- Web Application Penetration Testing
- Docker Security Testing
- Exploit Development
- Red Team Practice
- Learning Offensive Security

Unlike **HL-PWNBOX**, which is the attacking workstation, HL-VULBOX exists to be attacked.

It will host intentionally vulnerable applications and therefore **must never be exposed to the Internet**.

---

# HomeLab Position

```
                Internet
                    │
              Home Router
                    │
             192.168.0.0/24
                    │
             Proxmox Host
          192.168.0.200
                    │
    ┌───────────────┼───────────────┐
    │               │               │
HL-PWNBOX      HL-VULBOX      HL-SANDLIN
192.168.0.208 192.168.0.209 192.168.0.211
```

HL-PWNBOX performs the attacks.

HL-VULBOX hosts the vulnerable applications.

---

# Recommended VM Resources

| Resource | Recommended |
|----------|-------------|
| CPU | 4 vCPU |
| RAM | 8 GB |
| Disk | 100 GB |
| BIOS | OVMF (UEFI) |
| Machine Type | q35 |
| SCSI Controller | VirtIO SCSI |
| Network Adapter | VirtIO |
| Bridge | vmbr0 |
| QEMU Guest Agent | Enabled |

---

# VM Creation

Within Proxmox:

Create VM

```
Name
-----
HL-VULBOX
```

Select:

```
Guest OS
--------
Linux

Version
-------
6.x Kernel
```

Storage

```
100 GB
VirtIO SCSI
Discard Enabled
SSD Emulation Enabled
```

CPU

```
4 Cores

Type
Host
```

Memory

```
8192 MB
```

Networking

```
Bridge

vmbr0

Model

VirtIO
```

Finish the wizard.

Do NOT start the VM yet.

Enable:

```
Options

QEMU Guest Agent = Enabled
```

---

# Install Kali Linux

Mount the latest Kali Linux ISO.

Start the VM.

Follow the installation wizard.

Recommended options:

```
Hostname

HL-VULBOX
```

```
Domain

Leave Blank
```

Create your normal administrator account.

Do not use the root account for day-to-day work.

Use Guided Partitioning.

Allow the installer to use the entire virtual disk.

Complete installation.

Remove the ISO.

Reboot.

---

# Update the System

Immediately after installation:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo reboot
```

---

# Configure Static Networking

Check the interface name.

```bash
ip addr
```

Typically:

```
eth0
```

Edit the interfaces file.

```bash
sudo nano /etc/network/interfaces
```

Example configuration

```text
auto eth0

iface eth0 inet static

address 192.168.0.209

netmask 255.255.255.0

gateway 192.168.0.1

dns-nameservers 1.1.1.1 8.8.8.8
```

Restart networking.

```bash
sudo systemctl restart networking
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

Verify inside Proxmox that the VM status now reports the guest agent.

---

# Configure SSH

Install OpenSSH.

```bash
sudo apt install openssh-server -y
```

Enable the service.

```bash
sudo systemctl enable ssh

sudo systemctl start ssh
```

Verify.

```bash
systemctl status ssh
```

Harden SSH.

Edit:

```bash
sudo nano /etc/ssh/sshd_config
```

Recommended changes

```
PermitRootLogin no

PasswordAuthentication yes

PubkeyAuthentication yes
```

Restart SSH.

```bash
sudo systemctl restart ssh
```

Test from HL-PWNBOX.

```bash
ssh username@192.168.0.209
```

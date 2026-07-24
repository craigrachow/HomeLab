# HL-VULBOX - Kali Linux Vulnerable Lab Build Guide

# Overview
This document describes how to deploy HL-VULBOX on Proxmox as a dedicated deliberately vulnerable virtual machine used for learning, testing and practice.

Unlike **HL-PWNBOX**, which is the attacking workstation, HL-VULBOX exists to be attacked. 
It will host intentionally vulnerable applications and therefore **must never be exposed to the Internet**. It will also auto shutdown after 6 hours to limit attack surface.

Hostname: HL-VULBOX
IP Address: 192.168.0.209
OS: Kali Linux
Role: Vulnerable Testing Platform

---

# VM Resources

| Resource | Recommended |
|----------|-------------|
| CPU | 2 vCPU |
| RAM | 4 GB |
| Disk |80 GB |
| Network | VirtIO (bridged) |

---

# VM Creation
Within Proxmox, create the VM as per recommended specs and OS.

---

# Install Kali Linux
Upload Kali ISO to Proxmox → Create VM → Install with defaults.
Set hostname to HL-VULBOX and create user admin.

Start the VM.

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


## Final Checklist
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




Test from HL-PWNBOX.

```bash
ssh username@192.168.0.209
```

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

Immediately after installation update the system

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo reboot
```
---

# Set Static IP

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

# Enable SSH & Remote Desktop 

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```
---

## Step 4 – Install Docker and Docker Compose

```bash
sudo apt install -y docker-compose
```
Verify:
```bash
docker version
```
---

## Step 5 – Install Portainer
Done via deploy_containers.sh in  ./containers directory.
Must do a GitHub clone to get these scripts onto the server.

Access:
```
https://192.168.0.206:9443
```

---

## Step 6 – Install Cockpit

```bash
sudo apt install -y cockpit
sudo systemctl enable --now cockpit
```

Access:
```
https://192.168.0.206:9090
```

---

---

## Step 7 – Firewall

```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 9000
sudo ufw allow 9443
sudo ufw allow 9090
sudo ufw enable
```


---



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






Test from HL-PWNBOX.

```bash
ssh username@192.168.0.209
```

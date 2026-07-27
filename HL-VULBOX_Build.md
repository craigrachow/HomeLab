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
# Automated Configuration
```bash
chmod +x HL-VULBOX_Configure.sh
sudo ./HL-VULBOX_Configure.sh
```
The automated script will configure the VM performing the following steps.
 - Set the hostname
 - Updates and upgrades the OS
 - Sets a static IP on eth0
 - Installs and enables ssh and xrdp
 - Installs Docker and Docker Compose
 - Creates /containers directory and the requested subfolders
 - Writes the docker-compose.yml files
 - Starts the containers
 - Displays a verification summary and the URLs

---

# Manual Configuration
The following is a guide on how the system can be manually configured.  

### Set Static IP

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

### Enable SSH & Remote Desktop 

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```
---

### Install Docker and Docker Compose

```bash
sudo apt install -y docker-compose
```
Verify:
```bash
docker version
```
---

### Install Portainer
Done via deploy_containers.sh in  ./containers directory.
Must do a GitHub clone to get these scripts onto the server.

Access:
```
https://192.168.0.206:9443
```

---

### Install Cockpit

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

### Firewall

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

### Install QEMU Guest Agent

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

---

# Configure Remote Desktop (XRDP)

Although SSH will be your primary management interface, Remote Desktop provides an easy way to access Kali's graphical desktop when required.

## Install XRDP

```bash
sudo apt update
sudo apt install -y xrdp
```

Enable the service.

```bash
sudo systemctl enable xrdp
sudo systemctl start xrdp
```

Verify.

```bash
systemctl status xrdp
```

---

## Allow XRDP Through the Firewall

If UFW is enabled:

```bash
sudo ufw allow 3389/tcp
```

---

## Connect from Windows

Open **Remote Desktop Connection**.

Server

```
192.168.0.209
```

Login using your Kali username and password.

---

# Install Docker Engine

HL-VULBOX uses Docker to host intentionally vulnerable applications.
Docker keeps each application isolated and allows them to be rebuilt or destroyed quickly.

---

## Install Docker

```bash
curl -fsSL https://get.docker.com | sudo sh
```

Verify.

```bash
docker version
```

---

## Allow Current User to Manage Docker

```bash
sudo usermod -aG docker $USER
```

Refresh the group.

```bash
newgrp docker
```

Verify.

```bash
docker run hello-world
```

---

# Install Docker Compose

Ubuntu and Kali now use the Docker Compose Plugin.

Install it.

```bash
sudo apt install docker-compose-plugin -y
```

Verify.

```bash
docker compose version
```

---

# Create Container Directory Structure

All containers should be stored beneath a common root directory.

Create the directory.

```bash
sudo mkdir -p /containers
```

Recommended layout:

```
/containers

    ├── juiceshop
    │      docker-compose.yml
    │
    ├── dvwa
    │      docker-compose.yml
    │
    ├── mutillidae
    │      docker-compose.yml
    │
    ├── metasploitable3
    │
    └── portainer-agent
```

Keeping every application in its own folder makes backups, Git integration and upgrades much easier.

---

# Deploy OWASP Juice Shop

Juice Shop will be the primary vulnerable web application.

Create the directory.

```bash
mkdir -p /containers/juiceshop

cd /containers/juiceshop
```

Create:

```
docker-compose.yml
```

Contents:

```yaml
services:

  juiceshop:

    image: bkimminich/juice-shop

    container_name: juiceshop

    restart: unless-stopped

    ports:

      - "3000:3000"
```

Deploy.

```bash
docker compose up -d
```

Verify.

```bash
docker ps
```

Browse to

```
http://192.168.0.209:3000
```

---

# Deploy DVWA (Damn Vulnerable Web Application)

Create the folder.

```bash
mkdir -p /containers/dvwa

cd /containers/dvwa
```

Create:

```
docker-compose.yml
```

```yaml
services:

  dvwa:

    image: vulnerables/web-dvwa

    container_name: dvwa

    restart: unless-stopped

    ports:

      - "8080:80"
```

Deploy.

```bash
docker compose up -d
```

Access.

```
http://192.168.0.209:8080
```

---

# Deploy Mutillidae II

Mutillidae is another intentionally vulnerable application designed for OWASP Top 10 practice.

Create the folder.

```bash
mkdir -p /containers/mutillidae

cd /containers/mutillidae
```

Create:

```
docker-compose.yml
```

```yaml
services:

  mutillidae:

    image: citizenstig/nowasp

    container_name: mutillidae

    restart: unless-stopped

    ports:

      - "81:80"
```

Deploy.

```bash
docker compose up -d
```

Access.

```
http://192.168.0.209:81
```

---

# Optional – Install Portainer Agent

Your Portainer Server will live on **HL-DOCKER**.

HL-VULBOX only requires the lightweight Portainer Agent.

Create the folder.

```bash
mkdir -p /containers/portainer-agent

cd /containers/portainer-agent
```

Create:

```
docker-compose.yml
```

```yaml
services:

  agent:

    image: portainer/agent

    container_name: portainer-agent

    restart: unless-stopped

    ports:

      - "9001:9001"

    volumes:

      - /var/run/docker.sock:/var/run/docker.sock

      - /var/lib/docker/volumes:/var/lib/docker/volumes
```

Deploy.

```bash
docker compose up -d
```

---

# Verify Running Containers

```bash
docker ps
```

Expected output should include:

```
juiceshop

dvwa

mutillidae

portainer-agent
```

---

# Configure Docker to Start at Boot

```bash
sudo systemctl enable docker
```

Verify.

```bash
systemctl status docker
```

---

# Verify Network Connectivity

From HL-PWNBOX test each application.

```
http://192.168.0.209:3000

http://192.168.0.209:8080

http://192.168.0.209:81
```

Each page should load successfully.

---

# Notes

This server intentionally contains vulnerable software.

Do **not** install production applications here.

Do **not** expose any of these ports through your Internet router.

Keep the VM on your HomeLab LAN only.

The recommended workflow is:

```
HL-PWNBOX
        │
        │ Attack
        ▼
HL-VULBOX
        │
        ├── Juice Shop
        ├── DVWA
        ├── Mutillidae II
        └── Future vulnerable applications
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

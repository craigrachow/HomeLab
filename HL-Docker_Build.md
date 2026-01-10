# HL-DOCKER - Ubuntu Server Build Guide

## Overview
This document describes how to deploy **HL-DOCKER** on Proxmox as a dedicated container host using **Docker, Docker Compose, Portainer, and Cockpit**.

- **Hostname:** HL-DOCKER  
- **IP Address:** 192.168.0.206  
- **OS:** Ubuntu Server 22.04 LTS  
- **Role:** Container hosting platform  

---

## VM Specs (Recommended)

| Resource | Value |
|--------|-------|
| vCPU | 4 |
| RAM | 4 GB |
| Disk | 40 GB |
| Network | vmbr0 (bridged) |

---

## Step 1 – Install Ubuntu Server

Upload Ubuntu Server ISO to Proxmox → Create VM → Install with defaults.  
Set hostname to **HL-DOCKER** and create user `admin`.

---

## Step 2 - Set Static IP

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: no
      addresses: [192.168.0.206/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```

Apply:
```bash
sudo netplan apply
```

---

## Step 3 – Enable SSH

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

## Final Checklist

- [ ] Static IP set  
- [ ] SSH working  
- [ ] Docker running  
- [ ] Portainer reachable  
- [ ] Cockpit reachable  
- [ ] Backups configured  

---

**HL-DOCKER is now ready to host your HomeLab containers.**


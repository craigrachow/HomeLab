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

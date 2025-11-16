# instructions from here 

echo "Make Ansible Files"
sudo mkdir -pv ./ansible

echo "Create inventory.ini"
echo "# ============================================================
# HomeLab Ansible Inventory
# ============================================================

[all:vars]
ansible_user=admin
ansible_python_interpreter=/usr/bin/python3

# ------------------------------------------------------------
# Core Infrastructure Servers
# ------------------------------------------------------------
[core]
HL-RHServer ansible_host=192.168.0.205
HL-SANDLIN ansible_host=192.168.0.211

# ------------------------------------------------------------
# Security / Hacking / CTF Machines
# ------------------------------------------------------------
[ctf]
HL-PWNBOX ansible_host=192.168.0.208

# ------------------------------------------------------------
# Media & Docker Hosts (Future Expansion)
# ------------------------------------------------------------
[media]
HL-MEDIA ansible_host=192.168.0.206

[docker]
HL-DOCKER ansible_host=192.168.0.207

# ------------------------------------------------------------
# Vulnerable Machines (Juiceshop, Damn Vulnerable OS, etc.)
# ------------------------------------------------------------
[vuln]
HL-VULBOX ansible_host=192.168.0.209

# ------------------------------------------------------------
# Sandpit / Lab Testing Linux & Windows
# ------------------------------------------------------------
[sandpit-linux]
HL-SANDLIN ansible_host=192.168.0.211

[sandpit-win]
HL-SANDWIN ansible_host=192.168.0.212

# ------------------------------------------------------------
# Grouped Roles
# ------------------------------------------------------------
[nfs_servers]
HL-RHServer

[samba_servers]
HL-RHServer

[ansible_controllers]
HL-RHServer

[linux_servers:children]
core
ctf
media
docker
vuln
sandpit-linux

[windows_servers:children]
sandpit-win

# ------------------------------------------------------------
# Everything
# ------------------------------------------------------------
[homelab:children]
linux_servers
windows_servers" | sudo tee -a ./ansible/inventory.ini > /dev/null 





echo "Create ansible.cfg"
echo "[defaults]
inventory = inventory.ini
host_key_checking = False
retry_files_enabled = False
timeout = 30
forks = 10
remote_user = admin
ask_pass = False
roles_path = roles

[privilege_escalation]
become = True
become_method = sudo
become_ask_pass = False" | sudo tee -a ./ansible/ansible.cfg > /dev/null 




echo "Create ping_test.yml"
echo "---
- name: Test connectivity to all hosts
  hosts: all
  gather_facts: no

  tasks:
    - name: Ping test
      ansible.builtin.ping:"
 | sudo tee -a ./ansible/ping_test.yml > /dev/null 




echo "Create update_all.yml"
echo "---
- name: Update all Linux servers
  hosts: linux_servers
  become: yes

  tasks:
    - name: Update packages
      ansible.builtin.dnf:
        name: "*"
        state: latest" | sudo tee -a ./ansible/update_all.yml > /dev/null






echo "Create install_baseline_tools.yml"
echo "---
- name: Install baseline tools on all Linux hosts
  hosts: linux_servers
  become: yes

  tasks:
    - name: Install standard tools
      ansible.builtin.dnf:
        name:
          - vim
          - htop
          - git
          - curl
          - wget
        state: present" | sudo tee -a ./ansible/install_baseline_tools.yml > /dev/null






echo "Create harden_ssh.yml"
echo "---
- name: Harden SSH configuration
  hosts: linux_servers
  become: yes

  tasks:
    - name: Disable root SSH login
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PermitRootLogin'
        line: 'PermitRootLogin no'

    - name: Disable password authentication (optional - set true to enable)
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PasswordAuthentication'
        line: 'PasswordAuthentication yes'

    - name: Restart sshd
      ansible.builtin.service:
        name: sshd
        state: restarted" | sudo tee -a ./ansible/harden_ssh.yml > /dev/null 



#Create this folder structure: group_vars/  all.yml   linux_servers.yml     windows_servers.yml     ansible_controllers.yml     nfs_servers.yml



echo "Create all.yml"
echo "---
ansible_user: admin
ansible_python_interpreter: /usr/bin/python3

common_packages:
  - vim
  - htop
  - wget
  - curl
  - git" | sudo tee -a ./ansible/all.yml > /dev/null 






echo "Create linux_servers.yml"
echo "---
firewall_services:
  - ssh
  - samba
  - nfs
baseline_packages:
  - python3
  - policycoreutils
  - net-tools" | sudo tee -a ./ansible/linux_servers.yml > /dev/null  






echo "Create windows_servers.yml"
echo "---
ansible_connection: winrm
ansible_port: 5986
ansible_winrm_transport: basic
ansible_winrm_server_cert_validation: ignore" | sudo tee -a ./ansible/windows_servers.yml > /dev/null 





echo "Create ansible_controllers.yml"
echo "---
ansible_controller_tools:
  - ansible-core
  - git
  - python3-pip
  - sshpass" | sudo tee -a ./ansible/ansible_controllers.yml > /dev/null 





echo "Create nfs_servers.yml"
echo "---
nfs_export_path: "/srv/nfs/proxmox_backups"
nfs_allowed_network: "192.168.0.0/24"" | sudo tee -a ./ansible/nfs_servers.yml > /dev/null 







echo "Create site.yml"
echo "---
# ===============================================================
# Full HomeLab Orchestration Playbook
# ===============================================================

- import_playbook: ping_test.yml
- import_playbook: update_all.yml
- import_playbook: install_baseline_tools.yml
- import_playbook: harden_ssh.yml" | sudo tee -a ./ansible/site.yml > /dev/null 

 

 
echo "Ansible files done!"    

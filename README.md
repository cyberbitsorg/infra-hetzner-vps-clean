# Hetzner VPS Clean

Clean, reusable and secure VPS infrastructure with OpenTofu and Ansible.

## What this does

- Provisions a clean and secure VPS on Hetzner Cloud
- Installs Docker and basic security hardening
- No applications but ready for any containerized app you desire

## Quick Start

### 1. Create Hetzner API token

1. Go to [Hetzner Cloud Console](https://console.hetzner.cloud/)
2. Select or create your project
3. Go to **Security** → **API Tokens**
4. Generate token with Read & Write permissions

### 2. Upload SSH key to Hetzner

This project requires the SSH key to already exist in Hetzner Cloud.

Use [infra-hetzner-ssh](https://github.com/cyberbitsorg/infra-hetzner-ssh) to manage your SSH keys.

### 3. Create firewall

This project requires the firewall to already exist in Hetzner Cloud.

Use [infra-hetzner-firewall](https://github.com/cyberbitsorg/infra-hetzner-firewall) to manage your firewalls.

### 4. Configure

```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

Minimum required:

```hcl
hcloud_token   = "your-api-token"
admin_email    = "you@example.com"
domain         = "your-domain.com"
admin_username = "yourusername"
```

### 5. Deploy infrastructure

```bash
tofu init
tofu plan
tofu apply
```

Subsequent steps will be explained during deployment.

Get your admin password with:

```bash
tofu output -raw login_credentials
```

It is strongly advised to change it on your VPS.

## Security

- SSH. Key-only auth, root disabled, modern ciphers (ed25519/rsa-sha2), 3 max sessions, 5min timeout
- Firewall. UFW allows only 22/80/443
- Fail2Ban. 7-day bans, email alerts
- Kernel. SYN cookies, IP spoofing protection, ARP hardening
- Auto Updates. Security patches with reboot
- Audit. AppArmor + auditd logging

## Modifying with Ansible

After deployment, use Ansible to modify server configuration. Edit files in `ansible/roles/`, then re-run the playbook.

How it works: `ansible/inventory/terraform.py` runs `tofu output -json` to read server IP and settings from Tofu outputs, then exposes them as Ansible variables.

### Add a Package

Edit `ansible/roles/common/tasks/main.yaml`:

```yaml
- name: Install essential packages
  apt:
    name:
      - vim
      - htop
      - YOUR_PACKAGE_HERE    # Add your package
    state: present
```

Then run:

```bash
ansible-playbook -i ansible/inventory/terraform.py ansible/playbook.yaml
```

### Add a Sysctl Setting

Edit `ansible/roles/security/templates/99-security.conf.j2`:

```conf
net.ipv4.tcp_fastopen = 3
vm.vfs_cache_pressure = 50
```

Then re-run the playbook.

### Add a Cron Job

Edit `ansible/roles/common/tasks/main.yaml`:

```yaml
- name: Configure custom cron job
  cron:
    name: "Daily backup"
    minute: "0"
    hour: "3"
    job: "/usr/local/bin/backup.sh"
    user: "{{ admin_user }}"
```

### Add a User

Edit the playbook or create a new role:

```yaml
- name: Create additional user
  user:
    name: "developer"
    groups: sudo,docker
    shell: /bin/bash
    create_home: yes
  
- name: Add SSH key for developer
  authorized_key:
    user: "developer"
    key: "{{ lookup('file', '~/.ssh/developer.pub') }}"
```

## License

MIT License. Free to use. No warranties.

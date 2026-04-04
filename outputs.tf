# =============================================================================
# Server connection
# =============================================================================

output "server_ip" {
  description = "Server IPv4 address"
  value       = hcloud_server.vps.ipv4_address
}

output "login_credentials" {
  description = "Initial admin password (change after first login)"
  value       = <<-EOT
    Password: ${random_password.admin_password.result}
  EOT
  sensitive   = true
}

output "deployacc_sudo_password" {
  description = "deployacc sudo password (store in Ansible Vault)"
  value       = random_password.deployacc_sudo_password.result
  sensitive   = true
}

# =============================================================================
# Ansible configuration (read by ansible/inventory/terraform.py)
# =============================================================================

output "fqdn" {
  description = "FQDN - Fully Qualified Domain Name (read by Ansible)"
  value       = local.fqdn
}

output "base_domain" {
  description = "Base domain (read by Ansible)"
  value       = var.base_domain
}

output "system_email_prefix" {
  description = "Email sender prefix for system alerts (read by Ansible)"
  value       = var.system_email_prefix
}

output "smtp_host" {
  description = "SMTP server hostname (read by Ansible)"
  value       = var.smtp_host
}

output "smtp_port" {
  description = "SMTP server port (read by Ansible)"
  value       = var.smtp_port
}

output "smtp_user" {
  description = "SMTP username (read by Ansible)"
  value       = var.smtp_user
}

output "smtp_password" {
  description = "SMTP password (read by Ansible)"
  value       = var.smtp_password
  sensitive   = true
}

output "smtp_from" {
  description = "SMTP from address (read by Ansible)"
  value       = var.smtp_from != "" ? var.smtp_from : "${var.system_email_prefix}@${var.base_domain}"
}

output "admin_email" {
  description = "Admin email (read by Ansible)"
  value       = var.admin_email
}

output "admin_username" {
  description = "Admin username for SSH (read by Ansible)"
  value       = var.admin_username
}

output "docker_app_dirs" {
  description = "Base directories for Docker app deployments (read by Ansible)"
  value       = var.docker_app_dirs
}

# =============================================================================
# Next steps
# =============================================================================

output "z_next_steps" {
  description = "Complete setup guide"
  value       = <<-EOT

    Server IP: ${hcloud_server.vps.ipv4_address}

    === Complete the below is this is your first Tofu run ===

    1. Wait for cloud-init to complete:
       ssh deployacc@${hcloud_server.vps.ipv4_address} 'cloud-init status --wait'

    2. Get your admin password:
       tofu output -raw login_credentials

    3. SSH into your server and change your password:
       ssh ${var.admin_username}@${hcloud_server.vps.ipv4_address}

    4. Set up Ansible Vault (saves your passphrase to .vault_pass, gitignored):
       ./ansible-vault-setup.sh

    5. Run Ansible:
       ansible-playbook -i ansible/inventory/terraform.py ansible/playbook.yaml

  EOT
}

# =============================================================================
# Server connection
# =============================================================================

output "server_ip" {
  description = "Server IPv4 addresses, keyed by server name"
  value       = { for k, v in hcloud_server.vps : k => v.ipv4_address }
}

output "login_credentials" {
  description = "Initial admin passwords (change after first login), keyed by server name"
  value       = { for k, v in random_password.admin_password : k => "Password: ${v.result}" }
  sensitive   = true
}

output "deployacc_sudo_password" {
  description = "deployacc sudo passwords (store in Ansible Vault), keyed by server name"
  value       = { for k, v in random_password.deployacc_sudo_password : k => v.result }
  sensitive   = true
}

# =============================================================================
# Ansible configuration (read by ansible/inventory/terraform.py)
# =============================================================================

output "fqdn" {
  description = "FQDNs, keyed by server name (read by Ansible)"
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
  description = "Docker app directories per server (read by Ansible), keyed by server name"
  value       = { for k, v in var.servers : k => v.docker_app_dirs }
}

# =============================================================================
# Next steps
# =============================================================================

output "z_next_steps" {
  description = "Complete setup guide"
  value       = <<-EOT

    Servers:
    ${join("\n    ", [for k, v in hcloud_server.vps : "${k}: ${v.ipv4_address}"])}

    === Complete the below if this is your first Tofu run ===

    1. Wait for cloud-init to complete (run for each server):
    ${join("\n    ", [for k, v in hcloud_server.vps : "ssh deployacc@${v.ipv4_address} 'cloud-init status --wait'"])}

    2. Get admin passwords:
       tofu output -json login_credentials

    3. Set up Ansible Vault:
       ./ansible-vault-setup.sh

    4. Run Ansible:
       ansible-playbook -i ansible/inventory/terraform.py ansible/playbook.yaml

  EOT
}

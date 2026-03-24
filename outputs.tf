# =============================================================================
# Server Connection
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

# =============================================================================
# Ansible Configuration (read by ansible/inventory/terraform.py)
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

output "admin_email" {
  description = "Admin email (read by Ansible)"
  value       = var.admin_email
}

output "admin_username" {
  description = "Admin username for SSH (read by Ansible)"
  value       = var.admin_username
}

# =============================================================================
# Next Steps
# =============================================================================

output "next_steps" {
  description = "Complete setup guide"
  value       = <<-EOT

    === VPS IS READY ===

    Server IP: ${hcloud_server.vps.ipv4_address}

    === Complete the below is this is your first Tofu run ===

    1. Wait for cloud-init to complete:
       ssh deployacc@${hcloud_server.vps.ipv4_address} 'cloud-init status --wait'

    2. Get your admin password:
       tofu output -raw login_credentials

    3. SSH into your server and change your password:
       ssh ${var.admin_username}@${hcloud_server.vps.ipv4_address}

    4. Logout your VPS and run Ansible from your local host:
       ansible-playbook -i ansible/inventory/terraform.py ansible/playbook.yaml

  EOT
}

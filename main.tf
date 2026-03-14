# =============================================================================
# SSH Key (must exist in Hetzner - create in infra-hetzner-ssh first)
# =============================================================================

data "hcloud_ssh_key" "default" {
  name = var.ssh_key_name
}

# =============================================================================
# Firewall (must exist in Hetzner - create in infra-hetzner-firewall first)
# =============================================================================

data "hcloud_firewall" "default" {
  name = var.firewall_name
}

# =============================================================================
# Admin Password
# =============================================================================

resource "random_password" "admin_password" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# =============================================================================
# Server
# =============================================================================

resource "hcloud_server" "vps" {
  name        = var.server_name
  server_type = var.server_type
  location    = var.server_location
  image       = var.server_image
  backups     = var.server_backups

  ssh_keys     = [data.hcloud_ssh_key.default.id]
  firewall_ids = [data.hcloud_firewall.default.id]

  user_data = templatefile("${path.module}/cloud-init-bootstrap.yaml", {
    server_name    = var.server_name
    admin_username = var.admin_username
    ssh_public_key = file(pathexpand(var.ssh_public_key_path))
    timezone       = var.timezone
    domain         = local.full_domain
    admin_password = random_password.admin_password.result
  })

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  labels = local.labels

  lifecycle {
    ignore_changes = [user_data]
  }
}

# =============================================================================
# Reverse DNS (PTR record) - IPv4 only (IPv6 disabled)
# =============================================================================

resource "hcloud_rdns" "ipv4" {
  server_id  = hcloud_server.vps.id
  ip_address = hcloud_server.vps.ipv4_address
  dns_ptr    = local.full_domain
}

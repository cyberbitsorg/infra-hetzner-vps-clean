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
# Passwords (one pair per server)
# =============================================================================

resource "random_password" "admin_password" {
  for_each = var.servers
  length   = 32
  special  = false
  upper    = true
  lower    = true
  numeric  = true
}

resource "random_password" "deployacc_sudo_password" {
  for_each = var.servers
  length   = 32
  special  = false
  upper    = true
  lower    = true
  numeric  = true
}

# =============================================================================
# Servers
# =============================================================================

resource "hcloud_server" "vps" {
  for_each    = var.servers
  name        = each.key
  server_type = each.value.server_type
  location    = each.value.server_location
  image       = each.value.server_image
  backups     = each.value.server_backups

  ssh_keys     = [data.hcloud_ssh_key.default.id]
  firewall_ids = [data.hcloud_firewall.default.id]

  user_data = templatefile("${path.module}/cloud-init-bootstrap.yaml", {
    server_name             = each.key
    admin_username          = var.admin_username
    ssh_public_key          = file(pathexpand(var.ssh_public_key_path))
    timezone                = var.timezone
    fqdn                    = local.fqdn[each.key]
    admin_password          = random_password.admin_password[each.key].result
    deployacc_sudo_password = random_password.deployacc_sudo_password[each.key].result
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
  for_each   = var.servers
  server_id  = hcloud_server.vps[each.key].id
  ip_address = hcloud_server.vps[each.key].ipv4_address
  dns_ptr    = local.fqdn[each.key]
}

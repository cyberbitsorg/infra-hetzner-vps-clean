# =============================================================================
# Local values
# =============================================================================

locals {
  # Network CIDR blocks
  cidr_ipv4_all = var.cidr_ipv4_all
  cidr_ipv6_all = var.cidr_ipv6_all
  cidr_all      = [local.cidr_ipv4_all, local.cidr_ipv6_all]

  # Fully Qualified Domain Names, keyed by server name
  fqdn = { for k, _ in var.servers : k => "${k}.${var.base_domain}" }

  labels = {
    environment = var.environment
    managed_by  = var.managed_by
    domain      = var.base_domain
  }
}

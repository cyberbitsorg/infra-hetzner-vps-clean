# =============================================================================
# Local values
# =============================================================================

locals {
  # Network CIDR blocks
  cidr_ipv4_all = var.cidr_ipv4_all
  cidr_ipv6_all = var.cidr_ipv6_all
  cidr_all      = [local.cidr_ipv4_all, local.cidr_ipv6_all]

  # Fully Qualified Domain Name
  fqdn = "${var.server_name}.${var.base_domain}"

  labels = {
    environment = var.environment
    managed_by  = var.managed_by
    domain      = var.base_domain
  }
}

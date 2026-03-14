# =============================================================================
# Local Values
# =============================================================================

locals {
  # Network CIDR Blocks
  cidr_ipv4_all = var.cidr_ipv4_all
  cidr_ipv6_all = var.cidr_ipv6_all
  cidr_all      = [local.cidr_ipv4_all, local.cidr_ipv6_all]

  labels = {
    environment = var.environment
    managed_by  = var.managed_by
    domain      = var.domain
  }

  # Full domain: subdomain.domain.com or just domain.com
  full_domain = var.subdomain != "" ? "${var.subdomain}.${var.domain}" : var.domain
}

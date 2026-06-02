# =============================================================================
# Local values
# =============================================================================

locals {
  # Fully Qualified Domain Names, keyed by server name
  fqdn = { for k, _ in var.servers : k => "${k}.${var.base_domain}" }

  labels = {
    environment = var.environment
    managed_by  = var.managed_by
    domain      = var.base_domain
  }
}

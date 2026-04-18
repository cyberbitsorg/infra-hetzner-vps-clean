# =============================================================================
# Hetzner Cloud configuration
# =============================================================================

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

# =============================================================================
# Server configuration
# =============================================================================

variable "servers" {
  description = "Map of servers to provision. Key is used as server_name and Ansible inventory hostname."
  type = map(object({
    server_type     = string
    server_location = string
    server_image    = string
    server_backups  = bool
    docker_app_dirs = list(string)
  }))
}

# =============================================================================
# SSH configuration
# =============================================================================

variable "ssh_public_key_path" {
  description = "Path to your public SSH key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_key_name" {
  description = "Name of existing SSH key in Hetzner Cloud (create in infra-hetzner-ssh first)"
  type        = string
  default     = "main-deploy-key"
}

# =============================================================================
# User configuration
# =============================================================================

variable "admin_username" {
  description = "Name of the admin user (not root!)"
  type        = string
  default     = "admin"
}

variable "admin_email" {
  description = "Email for alerts and Let's Encrypt"
  type        = string
}

variable "timezone" {
  description = "Server timezone"
  type        = string
  default     = "Europe/Amsterdam"
}

# =============================================================================
# Domain configuration
# =============================================================================

variable "base_domain" {
  description = "Base domain name used to construct FQDN (e.g., example.com)"
  type        = string
  default     = "example.com"
}

variable "system_email_prefix" {
  description = "Email sender prefix for system alerts (before @domain, e.g., 'fail2ban' -> 'fail2ban@example.com')"
  type        = string
  default     = "fail2ban"
}

# =============================================================================
# SMTP configuration (for fail2ban alerts)
# =============================================================================

variable "smtp_host" {
  description = "SMTP server hostname (e.g., smtp.gmail.com, smtp.office365.com)"
  type        = string
  default     = ""
}

variable "smtp_port" {
  description = "SMTP server port (usually 587 for TLS)"
  type        = number
  default     = 587
}

variable "smtp_user" {
  description = "SMTP username for authentication"
  type        = string
  default     = ""
}

variable "smtp_password" {
  description = "SMTP password for authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "smtp_from" {
  description = "From address for emails (defaults to system_email_prefix@base_domain)"
  type        = string
  default     = ""
}

# =============================================================================
# Firewall configuration (managed in infra-hetzner-firewall)
# =============================================================================

variable "firewall_name" {
  description = "Name of existing firewall in Hetzner Cloud (create in infra-hetzner-firewall first)"
  type        = string
  default     = "main-web-firewall"
}

# =============================================================================
# Environment
# =============================================================================

variable "environment" {
  description = "Environment name for labeling (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

variable "managed_by" {
  description = "Name of the infrastructure management tool"
  type        = string
  default     = "opentofu"
}

variable "cidr_ipv4_all" {
  description = "CIDR block representing all IPv4 addresses"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cidr_ipv6_all" {
  description = "CIDR block representing all IPv6 addresses"
  type        = string
  default     = "::/0"
}

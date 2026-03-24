# =============================================================================
# Hetzner Cloud Configuration
# =============================================================================

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

# =============================================================================
# Server Configuration
# =============================================================================

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "web-vps"
}

variable "server_type" {
  description = "Hetzner server type (cpx11, cpx21, etc.)"
  type        = string
  default     = "cpx11"
}

variable "server_location" {
  description = "Datacenter location (fsn1, nbg1, hel1, ash, hil)"
  type        = string
  default     = "fsn1" # Falkenstein, Germany
}

variable "server_image" {
  description = "OS image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "server_backups" {
  description = "Enable automatic backups (20% additional cost)"
  type        = bool
  default     = true
}

# =============================================================================
# SSH Configuration
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
# User Configuration
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
# Domain Configuration
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
# Firewall Configuration (managed in infra-hetzner-firewall)
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

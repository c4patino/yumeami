terraform {
  backend "pg" {
    schema_name = "yumeami_cloudflare"
    conn_str    = "postgres://tsuki:5600/terraform?sslmode=disable"
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.28.1"
    }
  }
}

provider "cloudflare" {
  email   = var.cloudflare_api_email
  api_key = var.cloudflare_api_token
}

module "dns" {
  source = "./modules/dns"

  account_id = var.cloudflare_account_id
  zone_name  = var.zone_name
}

# module "tunnel" {
#   source = "./modules/tunnel"
#
#   account_id = var.cloudflare_account_id
#   zone_id    = module.dns.zone_id
# }

# module "access" {
#   source = "./modules/access"
#
#   account_id    = var.cloudflare_account_id
#   zone_id       = module.dns.zone_id
#   allowed_email = var.allowed_email
#   machines      = var.machines
#
#   access_base_domain       = var.access_base_domain
#   access_allowed_emails    = var.access_allowed_emails
#   access_allowed_group_ids = var.access_allowed_group_ids
#   session_duration         = var.session_duration
#   require_warp             = var.require_warp
#   split_tunnel_cidrs       = var.split_tunnel_cidrs
# }

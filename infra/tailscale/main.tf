terraform {
  backend "pg" {
    schema_name = "yumeami_tailscale"
    conn_str    = "postgres://tsuki:5600/terraform?sslmode=disable"
  }

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.29.3"
    }
  }
}

provider "tailscale" {
  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
  tailnet             = var.tailscale_tailnet_id
}

# =============================================================================
#  tailnet contact details
# =============================================================================

resource "tailscale_contacts" "default" {
  account {
    email = var.tailscale_email
  }

  support {
    email = var.tailscale_email
  }

  security {
    email = var.tailscale_email
  }
}

resource "tailscale_tailnet_settings" "default" {
  acls_externally_managed_on                  = false
  acls_external_link                          = "https://git.cpatino.com/c4patino/yumeami"
  devices_approval_on                         = true
  devices_auto_updates_on                     = true
  devices_key_duration_days                   = 180
  users_approval_on                           = true
  users_role_allowed_to_join_external_tailnet = "admin"
  posture_identity_collection_on              = false
  https_enabled                               = true
}

module "dns" {
  source = "./modules/dns"

  tailscale_oauth_client_id     = var.tailscale_oauth_client_id
  tailscale_oauth_client_secret = var.tailscale_oauth_client_secret
  tailscale_tailnet_id          = var.tailscale_tailnet_id

  magic_dns = true
  public_nameservers = [
    "100.101.224.25",
    "1.1.1.1",
    "8.8.8.8"
  ]
  split_dns = [
    {
      domain     = "cpatino.com"
      nameserver = "100.101.224.25"
    },
    {
      domain     = "yumeami.sh"
      nameserver = "100.101.224.25"
    }
  ]
}

module "devices" {
  source = "./modules/devices"

  tailscale_oauth_client_id     = var.tailscale_oauth_client_id
  tailscale_oauth_client_secret = var.tailscale_oauth_client_secret
  tailscale_tailnet_id          = var.tailscale_tailnet_id

  tailnet_domain = var.tailscale_tailnet_domain
  servers        = ["chibi", "shiori", "tsuki"]
  storage        = ["nas"]
}

module "acl" {
  source = "./modules/acl"

  tailscale_oauth_client_id     = var.tailscale_oauth_client_id
  tailscale_oauth_client_secret = var.tailscale_oauth_client_secret
  tailscale_tailnet_id          = var.tailscale_tailnet_id
}

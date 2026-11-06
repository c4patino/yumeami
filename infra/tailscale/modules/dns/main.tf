terraform {
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

resource "tailscale_dns_preferences" "preferences" {
  magic_dns = var.magic_dns
}

resource "tailscale_dns_nameservers" "nameservers" {
  nameservers = var.public_nameservers
}

resource "tailscale_dns_split_nameservers" "split" {
  for_each = { for i, v in var.split_dns : i => v }

  domain      = each.value.domain
  nameservers = [each.value.nameserver]
}

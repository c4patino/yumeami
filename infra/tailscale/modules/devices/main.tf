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

data "tailscale_device" "servers" {
  for_each = toset(var.servers)
  name     = "${each.key}.${var.tailnet_domain}"
}

data "tailscale_device" "storage" {
  for_each = toset(var.storage)
  name     = "${each.key}.${var.tailnet_domain}"
}

resource "tailscale_device_tags" "servers" {
  for_each = data.tailscale_device.servers

  device_id = each.value.id
  tags      = ["tag:server"]
}

resource "tailscale_device_tags" "storage" {
  for_each = data.tailscale_device.storage

  device_id = each.value.id
  tags      = ["tag:storage"]
}

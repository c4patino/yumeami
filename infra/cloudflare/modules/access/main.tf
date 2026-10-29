terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

#===============================================================================
#  Account Access Policies
#===============================================================================

resource "cloudflare_zero_trust_access_policy" "account_ingress" {
  account_id = var.account_id
  name       = "account ingress"
  decision   = "allow"

  include = [{
    email = {
      email = var.allowed_email
    }
  }]
}

# Disabled 2026-10-28 (destroyed in Cloudflare, kept for reference).
# Uncomment to bring back.
# resource "cloudflare_zero_trust_access_policy" "allow_c4patino" {
#   account_id = var.account_id
#   name       = "allow c4patino@gmail.com"
#   decision   = "allow"
#
#   include = [{
#     email = {
#       email = var.allowed_email
#     }
#   }]
# }

#===============================================================================
#  WARP Login App
#===============================================================================

resource "cloudflare_zero_trust_access_application" "warp_login" {
  account_id = var.account_id
  name       = "Warp Login App"
  type       = "warp"
  domain     = "yumeami.cloudflareaccess.com/warp"

  session_duration          = var.session_duration
  auto_redirect_to_identity = false

  policies = [{
    id         = cloudflare_zero_trust_access_policy.account_ingress.id
    precedence = 1
  }]
}

#===============================================================================
#  WARP Device Profiles
#===============================================================================

resource "cloudflare_zero_trust_device_custom_profile" "default" {
  account_id = var.account_id
  name       = "Default"
  enabled    = true
  precedence = 100
  match      = "identity.email == \"${var.allowed_email}\""

  allow_mode_switch              = false
  switch_locked                  = true
  allow_updates                  = true
  allowed_to_leave               = false
  register_interface_ip_with_dns = true
  tunnel_protocol                = "wireguard"
  auto_connect                   = 10

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

resource "cloudflare_zero_trust_device_default_profile" "split_tunnel" {
  account_id = var.account_id

  service_mode_v2 = {
    mode = "warp"
  }

  include = [
    for cidr in var.split_tunnel_cidrs : {
      address     = cidr
      description = "Infra network"
    }
  ]
}

#===============================================================================
#  Infrastructure Targets
#===============================================================================

locals {
  machines_with_ip = [for m in var.machines : m if try(m.ip, null) != null]
  machines_map     = { for m in local.machines_with_ip : m.name => m }
}

resource "cloudflare_zero_trust_access_infrastructure_target" "ssh" {
  for_each   = local.machines_map
  account_id = var.account_id

  hostname = each.key
  ip = {
    ipv4 = {
      ip_addr = each.value.ip
    }
  }
}

#===============================================================================
#  SSH Access Apps
#===============================================================================

resource "cloudflare_zero_trust_access_application" "ssh" {
  for_each   = var.access_base_domain != "" ? local.machines_map : {}
  account_id = var.account_id
  zone_id    = var.zone_id

  name                 = "ssh-${each.key}"
  type                 = "ssh"
  domain               = "${each.key}.${var.access_base_domain}"
  app_launcher_visible = true
  session_duration     = var.session_duration

  allow_authenticate_via_warp = var.require_warp

  destinations = [{
    cidr        = "${each.value.ip}/32"
    l4_protocol = "tcp"
    port_range  = tostring(try(each.value.ssh_port, 22))
    type        = "private"
  }]
}

resource "cloudflare_zero_trust_access_policy" "ssh" {
  for_each   = var.access_base_domain != "" ? local.machines_map : {}
  account_id = var.account_id
  name       = "allow-ssh-${each.key}"
  decision   = "allow"

  include = concat(
    [for g in var.access_allowed_group_ids : { group = { id = g } }],
    [for e in var.access_allowed_emails : { email = { email = e } }]
  )
}

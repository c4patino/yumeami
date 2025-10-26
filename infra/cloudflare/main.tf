terraform {
  backend "pg" {
    schema_name = "yumeami_cloudflare"
    conn_str = "postgres://shiori:5600/terraform?sslmode=disable"
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  email   = var.cloudflare_api_email
  api_key = var.cloudflare_api_token
}

resource "cloudflare_zone" "main" {
  name    = "cpatino.com"
  type    = "full"
  account = {
    id = var.cloudflare_account_id
  }
}

resource "cloudflare_dns_record" "wildcard_tunnel" {
  zone_id = cloudflare_zone.main.id
  name    = "*"
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.yumeami.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "root_github" {
  zone_id = cloudflare_zone.main.id
  name    = "cpatino.com"
  type    = "CNAME"
  content = "c4patino.github.io"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "www_github" {
  zone_id = cloudflare_zone.main.id
  name    = "www"
  type    = "CNAME"
  content = "c4patino.github.io"
  proxied = true
  ttl     = 1
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "yumeami" {
  account_id = var.cloudflare_account_id
  name       = "yumeami"
}

resource "cloudflare_zero_trust_access_policy" "account_ingress" {
  account_id = var.cloudflare_account_id
  name       = "account ingress"
  decision   = "allow"

  include = [{
    email = {
      email = var.allowed_email
    }
  }]
}

resource "cloudflare_zero_trust_access_policy" "allow_c4patino" {
  account_id = var.cloudflare_account_id
  name       = "allow c4patino@gmail.com"
  decision   = "allow"

  include = [{
    email = {
      email = var.allowed_email
    }
  }]
}

resource "cloudflare_zero_trust_device_custom_profile" "default" {
  account_id = var.cloudflare_account_id
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
}

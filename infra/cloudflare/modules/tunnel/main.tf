terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "yumeami" {
  account_id = var.account_id
  name       = "yumeami"
}

#===============================================================================
#  Wildcard DNS -> tunnel
#===============================================================================

resource "cloudflare_dns_record" "wildcard_tunnel" {
  zone_id = var.zone_id
  name    = "*"
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.yumeami.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

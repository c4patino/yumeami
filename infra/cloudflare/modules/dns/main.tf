terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

resource "cloudflare_zone" "main" {
  name = var.zone_name
  type = "full"
  account = {
    id = var.account_id
  }
}

#===============================================================================
#  GitHub Pages
#===============================================================================

resource "cloudflare_dns_record" "root_github" {
  zone_id = cloudflare_zone.main.id
  name    = var.zone_name
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

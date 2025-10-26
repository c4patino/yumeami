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
  api_token = var.cloudflare_api_token
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "yumeami" {
  account_id = var.cloudflare_account_id
  name       = "yumeami"
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

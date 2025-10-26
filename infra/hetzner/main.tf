terraform {
  backend "pg" {
    schema_name = "yumeami_hetzner"
    conn_str    = "postgres://shiori:5600/terraform?sslmode=disable"
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.42.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "tobira" {
  name = "tobira"

  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "ash"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  firewall_ids = [hcloud_firewall.primary.id]
  ssh_keys     = var.hcloud_ssh_keys
}

resource "hcloud_firewall" "primary" {
  name = "primary"

  rule {
    destination_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
    direction  = "out"
    port       = "any"
    protocol   = "tcp"
    source_ips = []
  }
  rule {
    destination_ips = []
    direction       = "in"
    port            = "any"
    protocol        = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }
}


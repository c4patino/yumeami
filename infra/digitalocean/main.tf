terraform {
  backend "pg" {
    schema_name = "yumeami_digitalocean"
    conn_str    = "postgres://tsuki:5600/terraform?sslmode=disable"
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.109.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

resource "digitalocean_project" "yumeami" {
  name       = "yumeami"
  is_default = true

  description = "yumeami infrastructure"
  purpose     = "Service or API"
  environment = "Production"

  resources = [
    digitalocean_droplet.tobira.urn,
  ]
}

resource "digitalocean_vpc" "nyc2" {
  name     = "default-nyc2"
  region   = "nyc2"
  ip_range = "10.100.0.0/20"
}

resource "digitalocean_vpc" "sfo2" {
  name     = "default-sfo2"
  region   = "sfo2"
  ip_range = "10.120.0.0/20"
}

resource "digitalocean_ssh_key" "default" {
  for_each = var.ssh_keys

  name       = each.key
  public_key = trimspace(file(pathexpand(each.value)))
}

moved {
  from = digitalocean_ssh_key.this
  to   = digitalocean_ssh_key.default
}

resource "digitalocean_droplet" "tobira" {
  name   = "tobira"
  image  = var.image
  region = var.region
  size   = var.size

  ipv6 = true

  ssh_keys = [for key in digitalocean_ssh_key.default : key.fingerprint]

  tags = [
    "yumeami",
  ]
}

resource "digitalocean_firewall" "primary" {
  name        = "primary"
  droplet_ids = [digitalocean_droplet.tobira.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

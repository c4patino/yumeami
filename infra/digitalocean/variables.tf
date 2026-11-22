variable "digitalocean_token" {
  description = "DigitalOcean API token."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region for the Droplet."
  type        = string
  default     = "nyc2"
}

variable "size" {
  description = "DigitalOcean Droplet size slug."
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "image" {
  description = "DigitalOcean base image slug. NixOS is installed over this image with nixos-anywhere."
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "ssh_keys" {
  description = "Map of DigitalOcean SSH key name to local public key path. Each key is uploaded and attached to the Droplet."
  type        = map(string)
  default = {
    c4patino  = "~/.ssh/id_ed25519.pub"
    deploy-rs = "~/.ssh/id_ed25519-deploy-rs.pub"
  }
}

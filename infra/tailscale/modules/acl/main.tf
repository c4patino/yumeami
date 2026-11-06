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

resource "tailscale_acl" "default" {
  overwrite_existing_content = true

  acl = jsonencode({
    hosts = {
      "arisu"  = "100.117.106.23",
      "kokoro" = "100.69.45.111",
      "chibi"  = "100.101.224.25",
      "tsuki"  = "100.71.23.30",
      "shiori" = "100.127.93.17",
    }

    groups = {}

    tagOwners = {
      "tag:server"  = ["autogroup:owner"]
      "tag:storage" = ["autogroup:owner"]
    }

    acls = [
      {
        action = "accept"
        src    = ["autogroup:owner"]
        dst    = ["*:*"]
      },
    ]

    nodeAttrs = [
      {
        target = ["tag:server"]
        attr   = ["drive:access", "drive:share", "funnel"]
      },
      {
        target = ["autogroup:owner"]
        attr   = ["drive:access", "drive:share"]
      },
    ]

    grants = [
      {
        src = ["tag:server", "tag:storage"]
        dst = ["tag:server", "tag:storage"]
        ip  = ["*"]
      },
    ]

    postures = {
      "posture:latestDesktop" : [
        "node:os IN ['linux', 'macos', 'windows']",
        "node:tsReleaseTrack == 'stable'",
      ],

      "posture:latestMobile" : ["node:os IN ['android', 'ios']", "node:tsReleaseTrack == 'stable'"],
    }

    ssh = []
  })
}

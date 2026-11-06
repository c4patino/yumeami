# Tailscale Terraform Setup

This directory manages Tailscale tailnet resources using Terraform.

---

## Layout

The configuration is split into submodules under `modules/`:

| Module      | Path                 | Contents                                           |
|-------------|----------------------|----------------------------------------------------|
| `dns`       | `modules/dns`        | DNS preferences, nameservers, and split DNS configs |
| `devices`   | `modules/devices`    | Device tags for servers and storage                 |
| `acl`       | `modules/acl`        | ACL rules, posture rules, and tailnet settings     |

Wiring (root `main.tf`):
- `contacts` -Contact details (remaining in root)
- `dns` - DNS configuration using magic DNS and split DNS
- `devices` - Applies `tag:server` and `tag:storage` to respective devices
- `acl` - Tailnet settings and ACL rules

---

## Prerequisites

- **Tailscale Tailnet:** Access to a Tailscale tailnet with admin permissions.
- **OAuth Client:** Create an OAuth client in the Tailscale console with appropriate permissions.
- **API Credentials:** Client ID and secret from your OAuth client.

---

## Configuration Variables

| Variable                   | Description                                    | Example/Default                     |
|----------------------------|------------------------------------------------|-------------------------------------|
| `tailscale_oauth_client_id`     | OAuth client ID                                | (required)                          |
| `tailscale_oauth_client_secret` | OAuth client secret                            | (required)                          |
| `tailscale_tailnet_id`          | Tailnet ID (optional if default)               | `"TeToZSS3vB21CNTRL"`               |
| `tailscale_tailnet_domain`      | Tailnet domain                                 | `"tail8b9fd9.ts.net"`               |
| `tailscale_email`               | Email for contacts                             | (required)                          |

---

## Usage Workflow

1. **Set environment variables:**
   ```bash
   export TF_VAR_tailscale_oauth_client_id="<your-client-id>"
   export TF_VAR_tailscale_oauth_client_secret="<your-client-secret>"
   export TF_VAR_tailscale_tailnet_id="<your-tailnet-id>"        # Optional
   export TF_VAR_tailscale_tailnet_domain="<your-tailnet-domain>" # Optional
   export TF_VAR_tailscale_email="<your-email>"
   ```

2. **Run Terraform:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

---

## Features

### Contacts
Configures account, support, and security contact emails (managed in root).

### DNS Configuration
- Magic DNS enabled
- Public DNS resolvers: Cloudflare (100.101.224.25), Google (1.1.1.1), and Google (8.8.8.8)
- Split DNS for `cpatino.com` and `yumeami.sh`

### Device Management
- Device tags applied: `tag:server` and `tag:storage`
- Device data sourced from tailnet for accurate IP tracking

### ACL Management
- Host IP mappings
- Tag owners for `server` and `storage` tags
- Access control lists (ACLs) for the tailnet
- Posture rules enforcing stable Tailscale versions
- SSH configuration (empty by default)
- Tailnet settings (dev approval, auto-updates, etc.)

---

## Outputs

| Output           | Description                               |
|------------------|-------------------------------------------|
| `all_devices`    | All devices in the tailnet                |
| `server_devices` | Server devices with their details         |
| `storage_devices`| Storage devices with their details        |
| `device_names`   | List of all device names (FQDN)           |

Run `terraform output` after apply to view device information.

---

## Destroying Resources

```bash
terraform destroy
```

**Note:** This will remove all Tailscale resources managed by Terraform.

# Cloudflare Zero Trust Terraform: Centralized Usage Guide

This repository manages Cloudflare Zero Trust, tunnels, DNS, and SSH Access resources using Terraform.

---

## Prerequisites

- **Cloudflare Zero Trust:** Enable at https://dash.cloudflare.com/zero-trust/onboarding
- **API Token:** Create with permissions for Zero Trust and Tunnel management.
- **Account ID:** Find in Cloudflare dashboard (User Profile > Account Home).

---

## Configuration Variables

| Variable                   | Description                                                                 | Example/Default                          |
|----------------------------|-----------------------------------------------------------------------------|------------------------------------------|
| `cloudflare_api_token`     | API token for Cloudflare                                                    | (required)                               |
| `cloudflare_account_id`    | Cloudflare account ID                                                       | (required)                               |
| `access_base_domain`       | Base domain for SSH apps (e.g., infra.cpatino.com)                          | `""` (disable Access apps)               |
| `access_allowed_emails`    | List of emails allowed to access SSH apps                                   | `[]`                                     |
| `access_allowed_group_ids` | List of Cloudflare Access group IDs allowed                                 | `[]`                                     |
| `session_duration`         | Access session duration for SSH apps                                        | `"24h"`                                  |
| `require_warp`             | If true, WARP auth is allowed for SSH apps                                  | `true`                                   |
| `split_tunnel_cidrs`       | CIDRs included in WARP split tunnel                                         | `["10.0.1.0/24"]`                        |
| `machines`                 | List of nodes: name, ip, ssh_port, description                              | See below                                |

**Example machines:**
```hcl
[
  { name = "arisu",  ip = "10.0.1.11", ssh_port = 22, description = "" },
  { name = "chibi",  ip = "10.0.1.12", ssh_port = 22, description = "" },
  { name = "kokoro", ip = "10.0.1.13", ssh_port = 22, description = "" },
  { name = "shiori", ip = "10.0.1.14", ssh_port = 22, description = "" }
]
```

---

## Usage Workflow

1. **Set environment variables (examples):**
   ```bash
   export TF_VAR_cloudflare_api_token="<your-token>"
   export TF_VAR_cloudflare_account_id="<your-account-id>"
   export TF_VAR_access_base_domain="infra.cpatino.com"
   export TF_VAR_access_allowed_emails='["c4patino@gmail.com"]'
   export TF_VAR_split_tunnel_cidrs='["10.0.1.0/24"]'
   export TF_VAR_machines='[
     {"name":"arisu","ip":"10.0.1.11","ssh_port":22,"description":""},
     {"name":"chibi","ip":"10.0.1.12","ssh_port":22,"description":""},
     {"name":"kokoro","ip":"10.0.1.13","ssh_port":22,"description":""},
     {"name":"shiori","ip":"10.0.1.14","ssh_port":22,"description":""}
   ]'
   ```

2. **Run Terraform:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

---

## Features & Operational Details

### WARP Split Tunnel (include mode)
- **Split tunnel is set via the Default Device Profile resource.**
- Only traffic to CIDRs in `split_tunnel_cidrs` goes through WARP.
- The Custom Device Profile is left unmanaged (`ignore_changes`) to avoid API PATCH errors.

### SSH over WARP via Access
- For each node with an IP:
  - Creates an infrastructure target (`cloudflare_zero_trust_access_infrastructure_target`)
  - Creates an SSH Access app with domain `<name>.<access_base_domain>`
  - Creates an Access allow policy for emails/groups you provide
- **SSH flow:** Use the Cloudflare WARP client (logged into your Zero Trust org), then:
  ```bash
  ssh user@arisu.infra.cpatino.com
  ```

### Tunnel Management
- Tunnel is created and credentials output for local management.
- Run `cloudflared` locally using these credentials:
  ```bash
  cloudflared tunnel --config /path/to/config.yml run yumeami
  ```

### Import Existing Tunnel
If you already have a tunnel named `yumeami`, import it into Terraform state:
1. Find your tunnel ID:
   ```bash
   cloudflared tunnel list
   ```
2. Import:
   ```bash
   terraform import cloudflare_zero_trust_tunnel_cloudflared.yumeami <account_id>/<tunnel_id>
   ```

---

## Troubleshooting & Notes

- **Device Profile PATCH errors:** Both custom and default device profiles can be flaky with API PATCH. Terraform is configured to avoid PATCH on the custom profile and only update split-tunnel includes on the default profile.
- **Access app creation:** Only nodes with a non-null IP and a non-empty `access_base_domain` will have Access apps/policies created.
- **WARP enforcement:** `require_warp` enables WARP authentication for SSH apps. For strict device posture enforcement, add a posture rule to your Access policies.
- **Zone alignment:** Ensure `access_base_domain` is a subdomain of your managed Cloudflare zone.

---

Let me know if you want this written to disk or further customized for your workflow!

# Cloudflare Zero Trust Terraform Setup

This directory manages Cloudflare Zero Trust resources using Terraform.

## Prerequisites
- Ensure your Cloudflare account has Zero Trust enabled: https://dash.cloudflare.com/zero-trust/onboarding
- Create an API token with permissions for Zero Trust and Tunnel management.
- Find your Cloudflare Account ID in the dashboard (User Profile > Account Home).
- Ensure you have a domain/hostname for your tunnel (e.g., `tunnel.yourdomain.com`).

## Usage
1. Set your API token, account ID, tunnel hostname, and allowed email as environment variables:
   ```bash
   export TF_VAR_cloudflare_api_token="<your-token>"
   export TF_VAR_cloudflare_account_id="<your-account-id>"
   export TF_VAR_allowed_email="c4patino@gmail.com"
   ```
2. Run Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Tunnel Management
- The tunnel will be created and credentials output for local management.
- You will run `cloudflared` locally using these credentials.
- Example usage after applying:
  ```bash
  cloudflared tunnel --config /path/to/config.yml run yumeami
  ```
- See [Cloudflare Tunnel docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) for details on local setup.

## Access Policies
- The tunnel is protected by a Zero Trust Access policy.
- Only clients authenticated as `c4patino@gmail.com` will be allowed.
- To change the allowed email, update `allowed_email` variable and re-apply.

### Example Policy Resource
```hcl
resource "cloudflare_zero_trust_access_policy" "allow_c4patino" {
  account_id = var.cloudflare_account_id
  name       = "Allow c4patino@gmail.com"
  decision   = "allow"
  precedence = 1

  include = [{
    email = {
      email = var.allowed_email
    }
  }]
}
```

## Import Existing Tunnel
If you already have a tunnel named `yumeami`, import it into Terraform state:
1. Find your tunnel ID:
   ```bash
   cloudflared tunnel list
   ```
2. Run the import command:
   ```bash
   terraform import cloudflare_zero_trust_tunnel_cloudflared.yumeami <account_id>/<tunnel_id>
   ```

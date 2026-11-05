# Hetzner Cloud Terraform Setup

This directory manages Hetzner Cloud resources using Terraform.

## Prerequisites
- Create a Hetzner Cloud API token: https://console.hetzner.cloud/projects
- (Optional) Register your SSH key in Hetzner Cloud for secure access.

## Usage
1. Set your API token as an environment variable:
   ```bash
   export TF_VAR_hcloud_token="<your-token>"
   ```
2. (Optional) Set SSH key names, image, and location:
   ```bash
   export TF_VAR_hcloud_ssh_keys='["your-key-name"]'
   ```
3. Run Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Outputs
- The server's public IPv4 address and ID will be shown after apply.

## Destroying the Server
```bash
terraform destroy
```

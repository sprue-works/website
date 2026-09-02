# Zone-level Cloudflare configuration for sprue.works that cannot live in
# wrangler.jsonc. Currently just the www -> apex redirect: Workers static-asset
# _redirects files accept only relative source paths, so a host-based redirect
# has to be a zone Redirect Rule.
#
# The Worker itself, its custom domains, and their DNS records are declared in
# wrangler.jsonc and created by `wrangler deploy`; Workers Builds (the GitHub
# connection) has no Terraform resource and is configured in the dashboard.
#
#   export CLOUDFLARE_API_TOKEN=...   # Zone:Read + Zone Rulesets (Dynamic Redirect):Edit
#   terraform init
#   terraform import cloudflare_ruleset.redirects zones/0a2832ed293070b06bd75cb7fc8db4d7/6ff4be8f4398429bbd7fbc9cc9487945
#   terraform plan                    # expect no changes

terraform {
  required_version = ">= 1.5"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {}

variable "zone_id" {
  description = "Cloudflare zone ID for sprue.works"
  type        = string
  default     = "0a2832ed293070b06bd75cb7fc8db4d7"
}

# A zone has exactly one ruleset per phase, so this resource owns every
# dynamic-redirect rule for sprue.works.
resource "cloudflare_ruleset" "redirects" {
  zone_id = var.zone_id
  name    = "default"
  phase   = "http_request_dynamic_redirect"
  kind    = "zone"

  rules = [
    {
      description = "www to apex"
      expression  = "(http.host eq \"www.sprue.works\")"
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code           = 301
          preserve_query_string = true
          target_url = {
            expression = "concat(\"https://sprue.works\", http.request.uri.path)"
          }
        }
      }
    }
  ]
}

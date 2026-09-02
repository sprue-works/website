# Cloudflare resources for sprue.works: the Pages project (connected to
# sprue-works/website), its custom domains, and the DNS records that point the
# apex and www at it. This repo owns its own records (infrastructure repo rule).
#
# One-time prerequisite that Terraform cannot do: install the Cloudflare Pages
# GitHub App on the sprue-works org (Cloudflare dashboard → Workers & Pages →
# Create → Pages → Connect to Git → authorise GitHub). After that:
#
#   export CLOUDFLARE_API_TOKEN=...          # Pages:Edit + DNS:Edit on the zone
#   export TF_VAR_account_id=...             # Cloudflare account ID
#   export TF_VAR_zone_id=...                # sprue.works zone ID
#   terraform init && terraform apply

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

variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID for sprue.works"
  type        = string
}

variable "project_name" {
  description = "Pages project name; previews are served from <branch>.<project_name>.pages.dev"
  type        = string
  default     = "sprue-works-website"
}

# ---- Pages project -----------------------------------------------------------

resource "cloudflare_pages_project" "site" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = "main"

  # Static site: no build step, serve the repo root.
  build_config = {
    build_command   = ""
    destination_dir = ""
    root_dir        = ""
  }

  source = {
    type = "github"
    config = {
      owner                          = "sprue-works"
      repo_name                      = "website"
      production_branch              = "main"
      production_deployments_enabled = true
      pr_comments_enabled            = true
      # Build a preview for every non-production branch.
      preview_deployment_setting = "all"
      preview_branch_includes    = ["*"]
      preview_branch_excludes    = []
    }
  }
}

# ---- Custom domains ----------------------------------------------------------

resource "cloudflare_pages_domain" "apex" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.site.name
  name         = "sprue.works"
}

resource "cloudflare_pages_domain" "www" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.site.name
  name         = "www.sprue.works"
}

# ---- DNS ---------------------------------------------------------------------

resource "cloudflare_dns_record" "apex" {
  zone_id = var.zone_id
  name    = "sprue.works"
  type    = "CNAME"
  content = cloudflare_pages_project.site.subdomain
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.zone_id
  name    = "www.sprue.works"
  type    = "CNAME"
  content = cloudflare_pages_project.site.subdomain
  proxied = true
  ttl     = 1
}

output "pages_subdomain" {
  value = cloudflare_pages_project.site.subdomain
}

# DNS records for sprue.works, pointing the apex and www at the Cloudflare
# Pages project. This repo owns its own records (infrastructure repo rule).
#
# Apply once the Pages project exists and the two custom domains have been
# added to it (see README.md). Requires CLOUDFLARE_API_TOKEN in the environment.

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
}

variable "pages_hostname" {
  description = "The Pages project's *.pages.dev hostname"
  type        = string
  default     = "sprue-works-website.pages.dev"
}

resource "cloudflare_dns_record" "apex" {
  zone_id = var.zone_id
  name    = "sprue.works"
  type    = "CNAME"
  content = var.pages_hostname
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.zone_id
  name    = "www"
  type    = "CNAME"
  content = var.pages_hostname
  proxied = true
  ttl     = 1
}

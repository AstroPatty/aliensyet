terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 5.11"
    }
  }
}

provider "cloudflare" {}

variable "account_id" { type = string }
variable "zone_id" { type = string }

resource "cloudflare_workers_script"  site {
  account_id = var.account_id
  script_name = "aliensyet"
  compatibility_date = "2026-11-01"
  assets = {
    directory = "${path.module}/public"
    config = {
      html_handling = "auto-trailing-slash"
    }
  }
}

resource "cloudflare_workers_custom_domain" "site" {
  account_id = var.account_id
  zone_id = var.zone_id
  hostname = "www.didwefindaliensyet.com"
  service    = cloudflare_workers_script.site.script_name
}

resource "cloudflare_workers_custom_domain" "apex" {
  account_id = var.account_id
  zone_id    = var.zone_id
  hostname   = "didwefindaliensyet.com"
  service    = cloudflare_workers_script.site.script_name
}

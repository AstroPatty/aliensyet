terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.11"
    }
  }
  backend "s3" {
    bucket                      = "aliens-tfstate"
    key                         = "site/terraform.tfstate"
    region                      = "auto"
    use_path_style              = true
    use_lockfile                = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

provider "cloudflare" {}

variable "account_id" {
  type      = string
  sensitive = true
}
variable "zone_id" {
  type      = string
  sensitive = true
}

resource "cloudflare_workers_script" "site" {
  account_id         = var.account_id
  script_name        = "aliensyet"
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
  zone_id    = var.zone_id
  hostname   = "www.didwefindaliensyet.com"
  service    = cloudflare_workers_script.site.script_name
}

resource "cloudflare_workers_custom_domain" "apex" {
  account_id = var.account_id
  zone_id    = var.zone_id
  hostname   = "didwefindaliensyet.com"
  service    = cloudflare_workers_script.site.script_name
}

resource "cloudflare_zero_trust_access_policy" "fd_ap" {
  account_id       = var.cf_account_id
  name             = "family-drive allowlist"
  decision         = "allow"
  session_duration = "24h"

  include = [
    {
      email = {
        email = var.fd_email_1
      }
    },
    {
      email = {
        email = var.fd_email_2
      }
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "fd_zt_app" {
  account_id                = var.cf_account_id
  name                      = "Албум на семейство Петрови"
  domain                    = "familydrive.${local.org}.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.fd_ap.id
      precedence = 1
    }
  ]
}

resource "cloudflare_d1_database" "family_drive_db" {
  account_id            = var.cf_account_id
  name                  = "${local.family_drive_name}-${var.env}-db"
  primary_location_hint = "EEUR"
  read_replication = {
    mode = "auto"
  }
}

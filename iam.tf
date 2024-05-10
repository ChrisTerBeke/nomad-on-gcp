resource "google_service_account" "nomad" {
  account_id = "nomad-agent"
  project    = var.project
}

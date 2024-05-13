resource "google_service_account" "nomad" {
  account_id = "nomad-agent"
  project    = var.project
}

# Allow nomad to see other GCE instances
resource "google_project_iam_member" "nomad_compute_viewer" {
  project = var.project
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.nomad.email}"
}

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

# Allow nomad to read/write GCE disks
resource "google_project_iam_member" "nomad_compute_instance_admin_v1" {
  project = var.project
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.nomad.email}"
}

resource "google_project_iam_member" "nomad_compute_service_account_user" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.nomad.email}"
}

# Allow nomad to read/write GCS buckets
resource "google_project_iam_member" "nomad_storage_admin" {
  project = var.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.nomad.email}"
}

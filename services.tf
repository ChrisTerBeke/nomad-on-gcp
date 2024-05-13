resource "google_project_service" "iap" {
  project = var.project
  service = "iap.googleapis.com"
}

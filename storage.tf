resource "google_compute_region_disk" "nomad_1" {
  project       = var.project
  name          = "nomad-csi-1"
  region        = var.region
  type          = "pd-ssd"
  size          = 200
  replica_zones = ["europe-west4-a", "europe-west4-b"]
}

resource "google_storage_bucket" "nomad_1" {
  name     = "summer-sun-394510-nomad-1"
  project  = var.project
  location = var.region
}

terraform {
  backend "gcs" {
    bucket = "summer-sun-394510-iac"
    prefix = "terraform/state/nomad-on-gcp"
  }
}

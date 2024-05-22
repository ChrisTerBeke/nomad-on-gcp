resource "google_iam_workload_identity_pool" "nomad" {
  workload_identity_pool_id = "nomad"
}

resource "google_iam_workload_identity_pool_provider" "nomad" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.nomad.workload_identity_pool_id
  workload_identity_pool_provider_id = "nomad"
  display_name                       = "Nomad Workloads"

  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  oidc {
    allowed_audiences = ["gcp"]
    issuer_uri        = "https://nomad.christerbeke.com"
  }
}

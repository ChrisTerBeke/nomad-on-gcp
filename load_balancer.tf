resource "google_compute_global_address" "nomad_ui" {
  name    = "nomad-ui"
  project = var.project
}

resource "google_compute_health_check" "nomad_ui" {
  name                = "nomad-ui"
  project             = var.project
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    port_name    = "nomad"
    request_path = "/ui/"
  }
}

resource "google_compute_backend_service" "nomad_ui" {
  name                  = "nomad-ui"
  project               = var.project
  health_checks         = [google_compute_health_check.nomad_ui.id]
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = "nomad"
  protocol              = "HTTP"
  timeout_sec           = 30

  backend {
    group           = google_compute_region_instance_group_manager.nomad_servers.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  iap {
    oauth2_client_id     = var.iap_client_id
    oauth2_client_secret = var.iap_client_secret
  }
}

resource "google_compute_url_map" "nomad_ui" {
  name            = "nomad-ui"
  project         = var.project
  default_service = google_compute_backend_service.nomad_ui.id
}

resource "google_compute_managed_ssl_certificate" "nomad_ui" {
  name    = "nomad-christerbeke-com"
  project = var.project

  managed {
    domains = ["nomad.christerbeke.com"]
  }
}

resource "google_compute_target_https_proxy" "nomad_ui" {
  name             = "nomad-ui"
  project          = var.project
  url_map          = google_compute_url_map.nomad_ui.id
  ssl_certificates = [google_compute_managed_ssl_certificate.nomad_ui.id]
}

resource "google_compute_global_forwarding_rule" "nomad_ui" {
  name                  = "nomad-ui"
  project               = var.project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443-443"
  target                = google_compute_target_https_proxy.nomad_ui.id
  ip_address            = google_compute_global_address.nomad_ui.id
}

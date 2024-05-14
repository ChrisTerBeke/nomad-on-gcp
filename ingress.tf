resource "google_compute_global_address" "nomad_public" {
  name    = "nomad-public"
  project = var.project
}

resource "google_compute_health_check" "nomad_public" {
  name                = "nomad-public"
  project             = var.project
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 10

  tcp_health_check {
    port_name = "http"
  }
}

resource "google_compute_backend_service" "nomad_public" {
  name                  = "nomad-public"
  project               = var.project
  health_checks         = [google_compute_health_check.nomad_public.id]
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 30

  backend {
    group           = google_compute_region_instance_group_manager.nomad_clients.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "nomad_public" {
  name            = "nomad-public"
  project         = var.project
  default_service = google_compute_backend_service.nomad_public.id
}

resource "google_compute_managed_ssl_certificate" "nomad_public" {
  name    = "public-christerbeke-com"
  project = var.project

  managed {
    domains = ["public.christerbeke.com"]
  }
}

resource "google_compute_target_https_proxy" "nomad_public" {
  name             = "nomad-public"
  project          = var.project
  url_map          = google_compute_url_map.nomad_public.id
  ssl_certificates = [google_compute_managed_ssl_certificate.nomad_public.id]
}

resource "google_compute_global_forwarding_rule" "nomad_public" {
  name                  = "nomad-public"
  project               = var.project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443-443"
  target                = google_compute_target_https_proxy.nomad_public.id
  ip_address            = google_compute_global_address.nomad_public.id
}

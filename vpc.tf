resource "google_compute_network" "nomad" {
  name                            = "nomad"
  project                         = var.project
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "nomad" {
  name                     = "nomad"
  ip_cidr_range            = "10.0.0.0/16"
  project                  = var.project
  region                   = var.region
  network                  = google_compute_network.nomad.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
  }
}

# TODO: restrict to ports that Nomad needs to run
resource "google_compute_firewall" "nomad_allow_internal_ingress" {
  name          = "allow-internal-ingress"
  project       = var.project
  network       = google_compute_network.nomad.name
  direction     = "INGRESS"
  source_ranges = ["10.0.0.0/16"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_route" "nomad_public_internet" {
  name             = "nomad-public-internet"
  project          = var.project
  network          = google_compute_network.nomad.id
  description      = "Custom static route to communicate with the public internet"
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

resource "google_compute_router" "nomad" {
  name    = "nomad_nat"
  project = var.project
  region  = var.region
  network = google_compute_network.nomad.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_address" "nomad_nat" {
  count   = 2
  name    = "nomad-${count.index}"
  project = var.project
  region  = var.region
}

resource "google_compute_router_nat" "nomad" {
  name                               = "nomad"
  router                             = google_compute_router.nomad.name
  project                            = var.project
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nomad.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

locals {
  /*  For more information on configuring IAP TCP forwarding see: 
  https://cloud.google.com/iap/docs/using-tcp-forwarding#create-firewall-rule  */
  iap_tcp_forwarding_cidr_range = "35.235.240.0/20"

  /*  For more information on configuring private Google access see: 
  https://cloud.google.com/vpc/docs/configure-private-google-access#config  */
  private_google_access_cidr_range    = "199.36.153.8/30"
  restricted_google_access_cidr_range = "199.36.153.4/30"

  private_service_access_dns_zones = {
    pkg-dev = {
      dns = "pkg.dev."
      ips = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
    }
    gcr-io = {
      dns = "gcr.io."
      ips = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
    }
    googleapis = {
      dns = "googleapis.com."
      ips = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
    }
  }
}

resource "google_compute_network" "default" {
  name                            = "nomad"
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
  project                         = var.project
}

resource "google_compute_subnetwork" "default" {
  name                     = "nomad"
  ip_cidr_range            = "10.0.0.0/16"
  region                   = var.region
  network                  = google_compute_network.default.id
  private_ip_google_access = true
  project                  = var.project
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
  }
}

# A route for public internet traffic
resource "google_compute_route" "public_internet" {
  network          = google_compute_network.default.id
  name             = "public-internet"
  description      = "Custom static route to communicate with the public internet"
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  project          = var.project
}

# Allow internal traffic within the network
resource "google_compute_firewall" "allow_internal_ingress" {
  name          = "allow-internal-ingress"
  network       = google_compute_network.default.name
  direction     = "INGRESS"
  source_ranges = ["10.128.0.0/9"]
  project       = var.project

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

# Allow incoming TCP traffic from Identity-Aware Proxy (IAP)
resource "google_compute_firewall" "allow_iap_tcp_ingress" {
  name          = "allow-iap-tcp-ingress"
  network       = google_compute_network.default.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = [local.iap_tcp_forwarding_cidr_range]

  allow {
    protocol = "tcp"
  }
}

# By default, deny all egress traffic
resource "google_compute_firewall" "deny_all_egress" {
  name               = "deny-all-egress"
  network            = google_compute_network.default.name
  project            = var.project
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  priority           = 65534

  deny {
    protocol = "all"
  }
}

resource "google_compute_network_firewall_policy" "nomad_bootstrap" {
  name        = "nomad-bootstrap"
  description = "Firewall policy to allow Nomad instances to bootstrap"
  project     = var.project
}

# Allow Nomad instances to communicate with only the FQDNs required for bootstrapping
resource "google_compute_network_firewall_policy_rule" "allow_nomad_bootstrap_egress" {
  firewall_policy         = google_compute_network_firewall_policy.nomad_bootstrap.name
  priority                = 1000
  action                  = "allow"
  direction               = "EGRESS"
  target_service_accounts = [google_service_account.nomad.email]
  project                 = var.project

  match {
    dest_fqdns = [
      "releases.hashicorp.com",
      "get.docker.com",
      "packages.debian.org",
      "debian.map.fastly.net",
      "deb.debian.org",
      "packages.cloud.google",
    ]

    layer4_configs {
      ip_protocol = "tcp"
    }
  }
}

# Associate the firewall policy with the network
resource "google_compute_network_firewall_policy_association" "primary" {
  name              = "nomad-bootstrap"
  attachment_target = google_compute_network.default.id
  firewall_policy   = google_compute_network_firewall_policy.nomad_bootstrap.name
  project           = var.project
}

# Allow private google access egress traffic
resource "google_compute_firewall" "allow_private_google_access_egress" {
  network     = google_compute_network.default.id
  name        = "allow-private-google-access-egress"
  description = "Allow private google access for all instances"
  priority    = 4000
  direction   = "EGRESS"
  target_tags = []
  project     = var.project

  destination_ranges = [
    local.private_google_access_cidr_range,
    local.restricted_google_access_cidr_range,
  ]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "default" {
  name    = "router"
  region  = var.region
  network = google_compute_network.default.id
  project = var.project

  bgp {
    asn = 64514
  }
}

# For redundancy, create two NAT IPs
resource "google_compute_address" "nat" {
  count   = 2
  name    = "nat-${count.index}"
  region  = var.region
  project = var.project
}

# Create a NAT gateway to allow instances without external IP addresses to access the internet
resource "google_compute_router_nat" "default" {
  name                               = "nat"
  router                             = google_compute_router.default.name
  region                             = google_compute_router.default.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat.*.self_link
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Create private DNS zones to route traffic to private google access IPs
resource "google_dns_managed_zone" "private_service_access" {
  for_each   = { for k, v in local.private_service_access_dns_zones : k => v }
  name       = each.key
  dns_name   = each.value.dns
  visibility = "private"
  project    = var.project

  private_visibility_config {
    dynamic "networks" {
      for_each = ["${google_compute_network.default.id}"]

      content {
        network_url = google_compute_network.default.id
      }
    }
  }
}

resource "google_dns_record_set" "a_records" {
  for_each = { for k, v in google_dns_managed_zone.private_service_access : k => v }

  name         = each.value.dns_name
  managed_zone = each.value.name
  type         = "A"
  ttl          = 300
  rrdatas      = local.private_service_access_dns_zones[each.key].ips
  project      = var.project
}

resource "google_dns_record_set" "cname_records" {
  for_each = { for k, v in google_dns_managed_zone.private_service_access : k => v }

  name         = "*.${each.value.dns_name}"
  managed_zone = each.value.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = [each.value.dns_name]
  project      = var.project
}

# Route private google access traffic to the default internet gateway
resource "google_compute_route" "private_google_access" {
  network          = google_compute_network.default.id
  name             = "private-google-access"
  description      = "Custom static route to communicate with Google APIs using private.googleapis.com"
  dest_range       = local.private_google_access_cidr_range
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  project          = var.project
}

# Route restricted google access traffic to the default internet gateway
resource "google_compute_route" "restricted_google_access" {
  network          = google_compute_network.default.id
  name             = "restricted-google-access"
  description      = "Custom static route to communicate with Google APIs using restricted.googleapis.com"
  dest_range       = local.restricted_google_access_cidr_range
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  project          = var.project
}

resource "google_compute_instance_template" "nomad_client" {
  name_prefix          = "nomad-client-"
  project              = var.project
  instance_description = "Nomad client"
  machine_type         = var.machine_type
  region               = var.region
  tags                 = ["nomad-client"]

  metadata = {
    google-logging-enabled = true
    enable-oslogin         = true
    block-project-ssh-keys = true
    user-data = templatefile("${path.module}/cloud_init.yaml", {
      nomad_version      = var.nomad_version
      nomad_server_tag   = local.nomad_server_tag
      gcp_project        = var.project
      nomad_client       = true
      nomad_server       = false
      nomad_datacenter   = var.nomad_datacenter
      nomad_server_count = var.nomad_server_count
    })
  }

  disk {
    source_image = var.base_image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork         = google_compute_subnetwork.default.id
    subnetwork_project = var.project
  }

  service_account {
    email  = google_service_account.nomad.email
    scopes = ["cloud-platform"]
  }

  # instance Templates cannot be updated after creation.
  # in order to update an Instance Template, Terraform will destroy the existing resource and create a replacement
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "nomad_clients" {
  provider           = google-beta
  name               = "nomad-clients"
  project            = var.project
  region             = var.region
  base_instance_name = "nomad-client"

  version {
    instance_template = google_compute_instance_template.nomad_client.id
  }

  update_policy {
    minimal_action               = "REPLACE"
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    replacement_method           = "SUBSTITUTE"
    max_surge_fixed              = 3 # number of zones
    max_unavailable_fixed        = 0 # always create new clients before destroying old ones
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.nomad_clients.id
    initial_delay_sec = 120
  }

  named_port {
    name = "nomad"
    port = 4646
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_region_autoscaler" "nomad_clients" {
  name    = "nomad-clients-autoscaler"
  project = var.project
  region  = var.region
  target  = google_compute_region_instance_group_manager.nomad_clients.id

  autoscaling_policy {
    max_replicas    = var.nomad_max_client_count
    min_replicas    = var.nomad_client_count
    cooldown_period = 120

    cpu_utilization {
      target = 0.75
    }
  }
}

resource "google_compute_health_check" "nomad_clients" {
  name                = "nomad-clients-health-check"
  project             = var.project
  check_interval_sec  = 10
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 10

  tcp_health_check {
    port_name = "nomad"
  }
}

resource "google_compute_instance_template" "nomad_server_cos" {
  name_prefix          = "nomad-server-cos-"
  project              = var.project
  instance_description = "Nomad server COS"
  machine_type         = var.machine_type
  region               = var.region
  tags                 = [local.nomad_server_tag]

  metadata = {
    google-logging-enabled = true
    enable-oslogin         = true
    block-project-ssh-keys = true
    user-data = templatefile("${path.module}/cloud_init_cos.yaml", {
      gcp_project        = var.project
      nomad_version      = var.nomad_version
      nomad_client       = false
      nomad_server       = true
      nomad_server_count = var.nomad_server_count
      nomad_server_tag   = local.nomad_server_tag
      nomad_datacenter   = var.nomad_datacenter
    })
  }

  disk {
    source_image = "cos-cloud/cos-113-lts"
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

resource "google_compute_region_instance_group_manager" "nomad_servers_cos" {
  provider           = google-beta
  name               = "nomad-servers-cos"
  project            = var.project
  region             = var.region
  base_instance_name = "nomad-server-cos"

  version {
    instance_template = google_compute_instance_template.nomad_server_cos.id
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
    health_check      = google_compute_health_check.nomad_servers.id
    initial_delay_sec = 30
  }

  named_port {
    name = "nomad"
    port = var.nomad_agent_port
  }
}

resource "google_compute_region_autoscaler" "nomad_servers_cos" {
  name    = "nomad-servers-cos"
  project = var.project
  region  = var.region
  target  = google_compute_region_instance_group_manager.nomad_servers_cos.id

  autoscaling_policy {
    max_replicas = var.nomad_max_server_count
    min_replicas = var.nomad_server_count

    cpu_utilization {
      target = 0.75
    }
  }
}

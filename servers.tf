locals {
  nomad_server_tag = "nomad-server"
}

resource "google_compute_instance_template" "nomad_server" {
  name_prefix          = "nomad-server-"
  project              = var.project
  instance_description = "Nomad server"
  machine_type         = var.machine_type
  region               = var.region
  tags                 = [local.nomad_server_tag]

  metadata = {
    google-logging-enabled = true
    enable-oslogin         = true
    block-project-ssh-keys = true
    user-data = templatefile("${path.module}/cloud_init.yaml", {
      nomad_version      = var.nomad_version
      gcp_project        = var.project
      nomad_client       = false
      nomad_server       = true
      nomad_datacenter   = var.nomad_datacenter
      nomad_server_count = var.nomad_server_count
      nomad_server_tag   = local.nomad_server_tag
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

resource "google_compute_instance_group_manager" "nomad_servers" {
  name               = "nomad-servers"
  project            = var.project
  zone               = "${var.region}-a" # TODO: support multiple zones
  base_instance_name = "nomad-server"
  target_size        = var.nomad_server_count

  version {
    instance_template = google_compute_instance_template.nomad_server.id
  }
}

resource "google_compute_instance_template" "nomad_client" {
  name                 = "nomad-client"
  project              = var.project
  instance_description = "Nomad client"
  machine_type         = var.machine_type
  region               = var.region
  tags                 = ["nomad-client"]

  metadata = {
    google-logging-enabled = true
    enable-oslogin         = true
    block-project-ssh-keys = true
    startup-script         = "apt-get install cloud-init"
    user-data = templatefile("${path.module}/cloud_init.yaml", {
      nomad_version = var.nomad_version
      nomad_config = templatefile("${path.module}/overlay/etc/nomad.d/nomad.hcl", {
        nomad_server       = false
        nomad_client       = true
        nomad_datacenter   = var.nomad_datacenter
        nomad_server_count = var.nomad_server_count
      })
      nomad_systemd_service = templatefile("${path.module}/overlay/etc/systemd/system/nomad.service", {
        nomad_server = false
        nomad_client = true
      })
      init_script = templatefile("${path.module}/overlay/opt/init/init.sh", {
        nomad_version = var.nomad_version
      })
    })
  }

  disk {
    source_image = var.base_image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork         = google_compute_subnetwork.nomad.id
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

resource "google_compute_instance_group_manager" "nomad_clients" {
  name               = "nomad-clients"
  project            = var.project
  zone               = "${var.region}-a" # TODO: support multiple zones
  base_instance_name = "nomad-client"
  target_size        = var.nomad_client_count

  version {
    instance_template = google_compute_instance_template.nomad_client.id
  }
}

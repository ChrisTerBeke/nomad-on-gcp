resource "google_compute_instance_template" "nomad_server" {
  name_prefix          = "nomad-server-"
  project              = var.project
  instance_description = "Nomad server"
  machine_type         = var.machine_type
  region               = var.region
  tags                 = ["nomad-server"]

  metadata = {
    google-logging-enabled = true
    enable-oslogin         = true
    block-project-ssh-keys = true
    startup-script         = "apt-get install -y cloud-init"
    user-data = templatefile("${path.module}/cloud_init.yaml", {
      nomad_version = var.nomad_version
      nomad_config = templatefile("${path.module}/overlay/etc/nomad.d/nomad.hcl", {
        nomad_server       = true
        nomad_client       = false
        nomad_datacenter   = var.nomad_datacenter
        nomad_server_count = var.nomad_server_count
      })
      nomad_systemd_service = templatefile("${path.module}/overlay/etc/systemd/system/nomad.service", {
        nomad_server = true
        nomad_client = false
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

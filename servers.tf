resource "google_compute_instance_template" "nomad_server" {
  name         = "nomad-server"
  machine_type = var.machine_type

  metadata = {
    google-logging-enabled = true
    enable-oslogin         = true
    block-project-ssh-keys = true
    user-data = templatefile("${path.module}/cloud_init.yaml", {
      nomad_version = var.nomad_version
      nomad_config = templatefile("${path.module}/etc/nomad.d/nomad.hcl", {
        nomad_server       = true
        nomad_client       = false
        nomad_datacenter   = var.nomad_datacenter
        nomad_server_count = var.nomad_server_count
      })
      nomad_systemd_service = templatefile("${path.module}/etc/systemd/system/nomad.service", {
        nomad_server = true
        nomad_client = false
      })
      init_script = templatefile("${path.module}/overlay/opt/init/init.sh", {
        nomad_server = true
        nomad_client = false
      })
    })
  }

  disk {
    source_image = var.base_image
  }

  network_interface {
    subnetwork = google_compute_subnetwork.nomad.id
  }

  service_account {
    email  = google_service_account.nomad.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "nomad_servers" {
  name               = "nomad-servers"
  base_instance_name = "nomad-server"
  target_size        = var.nomad_server_count

  version {
    instance_template = google_compute_instance_template.nomad_server.self_link
  }
}

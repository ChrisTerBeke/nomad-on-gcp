resource "google_compute_instance_template" "nomad_client" {
  name         = "nomad-client"
  machine_type = var.machine_type

  metadata = {
    google-logging-enabled = true
    enable-oslogin         = true
    block-project-ssh-keys = true
    user-data = templatefile("${path.module}/cloud_init.yaml", {
      nomad_version = var.nomad_version
      nomad_config = templatefile("${path.module}/etc/nomad.d/nomad.hcl", {
        nomad_server       = false
        nomad_client       = true
        nomad_datacenter   = var.nomad_datacenter
        nomad_server_count = var.nomad_server_count
      })
      nomad_systemd_service = templatefile("${path.module}/etc/systemd/system/nomad.service", {
        nomad_server = false
        nomad_client = true
      })
      init_script = templatefile("${path.module}/init.sh", {
        nomad_server = false
        nomad_client = true
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

resource "google_compute_instance_group_manager" "nomad_clients" {
  name               = "nomad-clients"
  base_instance_name = "nomad-client"
  target_size        = var.nomad_client_count

  version {
    instance_template = google_compute_instance_template.nomad_client.self_link
  }
}

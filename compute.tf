resource "google_compute_instance_template" "server" {
  name         = "nomad-server"
  machine_type = var.machine_type

  metadata = {
    google-logging-enabled = true
    enable-oslogin         = true
    block-project-ssh-keys = true
    user-data = templatefile("${path.module}/cloud_init.yaml", {
      nomad_version      = var.nomad_version
      nomad_bind_addr    = var.nomad_bind_addr
      nomad_server_count = var.nomad_server_count
      nomad_datacenter   = var.nomad_datacenter
      nomad_server       = true
      nomad_client       = false
    })
  }

  disk {
    source_image = var.base_image
  }
}

resource "google_compute_instance_group_manager" "servers" {
  name               = "nomad-servers"
  base_instance_name = "nomad-server"
  target_size        = var.nomad_server_count

  version {
    instance_template = google_compute_instance_template.server.self_link
  }
}

resource "google_compute_instance_template" "client" {
  name         = "nomad-client"
  machine_type = var.machine_type

  metadata = {
    google-logging-enabled = true
    enable-oslogin         = true
    block-project-ssh-keys = true
    user-data = templatefile("${path.module}/cloud_init.yaml", {
      nomad_version      = var.nomad_version
      nomad_bind_addr    = var.nomad_bind_addr
      nomad_server_count = var.nomad_server_count
      nomad_datacenter   = var.nomad_datacenter
      nomad_server       = false
      nomad_client       = true
    })
  }

  disk {
    source_image = var.base_image
  }
}

resource "google_compute_instance_group_manager" "clients" {
  name               = "nomad-clients"
  base_instance_name = "nomad-client"
  target_size        = var.nomad_client_count

  version {
    instance_template = google_compute_instance_template.client.self_link
  }
}

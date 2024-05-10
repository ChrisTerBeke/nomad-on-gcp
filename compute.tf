resource "google_compute_instance_template" "server" {
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
}

resource "google_compute_instance_group_manager" "clients" {
  name               = "nomad-clients"
  base_instance_name = "nomad-client"
  target_size        = var.nomad_client_count

  version {
    instance_template = google_compute_instance_template.client.self_link
  }
}

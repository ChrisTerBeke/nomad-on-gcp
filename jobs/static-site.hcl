job "static-site" {
  datacenters = ["gcp-eu"]

  group "example" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = 80
      }
    }

    service {
      provider = "nomad"
      name     = "storage"
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=PathPrefix(`/storage`)",
        "traefik.http.middlewares.stripprefix.stripprefix.prefixes=/storage",
        "traefik.http.routers.http.middlewares=stripprefix",
      ]
    }

    volume "static" {
      type            = "csi"
      read_only       = false
      source          = "fuse-1"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "server" {
      driver = "docker"

      volume_mount {
        volume      = "static"
        destination = "/static"
        read_only   = false
      }

      config {
        image = "flashspys/nginx-static"
        ports = ["http"]
      }
    }
  }
}

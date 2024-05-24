job "static-site" {
  datacenters = ["gcp-eu"]

  group "storage" {
    count = 3

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
        "traefik.http.routers.static.rule=PathPrefix(`/static`)",
        "traefik.http.middlewares.static.stripprefix.prefixes=/static",
        "traefik.http.routers.static.middlewares=static",
      ]
    }

    task "server" {
      driver = "docker"

      volume_mount {
        volume      = "static"
        destination = "/static"
      }

      config {
        image = "flashspys/nginx-static"
        ports = ["http"]
      }
    }

    volume "static" {
      type            = "csi"
      source          = "fuse-1"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
  }
}

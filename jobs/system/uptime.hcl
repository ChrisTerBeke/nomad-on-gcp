job "uptime" {
  datacenters = ["gcp-eu"]

  group "uptime" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = 3001
      }
    }

    service {
      provider = "nomad"
      name     = "uptime"
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.uptime.rule=Host(`uptime.christerbeke.com`)",
      ]
    }

    task "uptime" {
      driver = "docker"

      volume_mount {
        volume      = "data"
        destination = "/app/data"
      }

      config {
        image = "louislam/uptime-kuma:1"
        ports = ["http"]
      }
    }

    volume "data" {
      type            = "csi"
      source          = "fuse-1"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
  }
}

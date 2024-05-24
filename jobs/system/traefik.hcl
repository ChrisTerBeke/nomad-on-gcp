job "traefik" {
  datacenters = ["gcp-eu"]
  type        = "system"

  update {
		max_parallel = 1
  }

  group "traefik" {

    network {
      port "http" {
        static = 80
        to     = 80
      }

      port "dashboard" {
      	to = 8081
      }
    }

    service {
      name     = "traefik-http"
      provider = "nomad"
      port     = "http"
    }

    service {
      name     = "traefik-dashboard"
      provider = "nomad"
      port     = "dashboard"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik.rule=Host(`traefik.christerbeke.com`)",
      ]
    }

    task "server" {
      driver = "docker"

      config {
        image = "traefik:3.0.0"
        ports = ["http", "dashboard"]
        args  = [
          "--api.dashboard=true",
          "--api.insecure=true",
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_dashboard}",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://${NOMAD_IP_http}:4646"
        ]
      }
    }
  }
}

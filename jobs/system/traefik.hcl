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
        "traefik.http.middlewares.traefik.basicauth.users=admin:$2a$13$368u26kV29bL8W7ei/3g1ui1o7ERzo4WMw.A96EQ7z2KczXrWD6.S",
        "traefik.http.routers.traefik.middlewares=traefik",
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
          "--providers.nomad.endpoint.address=http://${NOMAD_IP_http}:4646",
          "--providers.nomad.exposedByDefault=false",
        ]
      }
    }
  }
}

job "example" {
  datacenters = ["gcp-eu"]

  spread {
    attribute = "${node.unique.id}"
    weight    = 100
  }

  group "example" {
    count = 3

    network {
      mode = "bridge"

      port "http" {
        to = 80
      }
    }

    service {
      provider = "nomad"
      name     = "echo"
      port     = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.echo.rule=PathPrefix(`/echo`)",
        "traefik.http.middlewares.echo.stripprefix.prefixes=/echo",
        "traefik.http.routers.echo.middlewares=echo",
      ]
    }

    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":${NOMAD_PORT_http}",
          "-text",
          "hello world from Node: ${node.unique.id}, Alloc: ${NOMAD_ALLOC_ID}",
        ]
      }
    }
  }
}

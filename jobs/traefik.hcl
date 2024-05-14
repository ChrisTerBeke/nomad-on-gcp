job "traefik" {
  datacenters = ["gcp-eu"]
  type        = "system"

  group "traefik" {

    network {
      port "http"{
         static = 80
      }
      
      port "admin"{
         static = 8080
      }
    }

    service {
      name     = "traefik-http"
      provider = "nomad"
      port     = "http"
    }

    task "server" {
      driver = "docker"
 
      config {
        image = "traefik:3.0.0"
        ports = ["admin", "http"]
        args  = [
          "--api.dashboard=true",
          "--api.insecure=true",
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://${NOMAD_IP_http}:4646"
        ]
      }
    }
  }
}
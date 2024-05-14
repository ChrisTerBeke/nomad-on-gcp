job "example" {
  datacenters = ["gcp-eu"]
  
  spread {
    attribute = "${node.unique.id}"
    weight    = 100
  }
 
  group "example" {
    count = 20

    network {
      mode = "bridge"
      
      port "http" {
        to = "80"
      }
    }
    
    service {
      provider = "nomad"
      name     = "echo"
      port     = "http"
      
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Host(`public.christerbeke.com`)"
      ]
    }
    
    task "server" {
      driver = "docker"
 
      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":80",
          "-text",
          "hello world",
        ]
      }
    }
  }
}

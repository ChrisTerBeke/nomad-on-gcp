job "example-with-storage" {
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
        "traefik.http.routers.http.rule=Path(`/storage`)",
      ]
    }

    volume "store" {
      type            = "csi"
      read_only       = false
      source          = "fuse-1"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    volume "fuse" {
      type            = "csi"
      read_only       = false
      source          = "fuse-1"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "server" {
      driver = "docker"

      volume_mount {
        volume      = "store"
        destination = "/mnt/disks/store"
        read_only   = false
      }

      volume_mount {
        volume      = "fuse"
        destination = "/mnt/disks/fuse"
        read_only   = false
      }

      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":${NOMAD_PORT_http}",
          "-text",
          "hello world from CSI storage Node: ${node.unique.id}, Alloc: ${NOMAD_ALLOC_ID}",
        ]
      }
    }
  }
}

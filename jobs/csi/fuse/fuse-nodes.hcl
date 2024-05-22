job "fuse-nodes" {
  datacenters = ["gcp-eu"]
  type        = "system"

  group "nodes" {
    task "plugin" {
      driver = "docker"

      config {
        image      = "docker.io/ofekmeister/csi-gcs:v0.9.0"
        privileged = true
        args = [
          "-v=5",
          "-node-name=${node.unique.id}",
        ]
      }

      csi_plugin {
        id        = "fuse"
        type      = "node"
        mount_dir = "/csi"
      }
    }
  }
}

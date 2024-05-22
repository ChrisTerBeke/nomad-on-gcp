job "fuse-controller" {
  datacenters = ["gcp-eu"]

  group "controller" {
    task "plugin" {
      driver = "docker"

      config {
        image = "docker.io/ofekmeister/csi-gcs:v0.9.0"
        args  = ["-node-name=${node.unique.id}"]
      }

      csi_plugin {
        id        = "fuse"
        type      = "controller"
        mount_dir = "/csi"
      }
    }
  }
}

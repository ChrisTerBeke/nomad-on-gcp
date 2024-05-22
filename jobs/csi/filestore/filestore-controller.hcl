job "filestore-controller" {
  datacenters = ["gcp-eu"]
  
  group "controller" {
    task "plugin" {
      driver = "docker"

      config {
        image = "registry.k8s.io/cloud-provider-gcp/gcp-filestore-csi-driver:v1.6.13"
        args = [
          "--endpoint=unix:///csi/csi.sock",
          "--nodeid=${node.unique.id}",
          "--controller=true",
        ]
      }
      
      csi_plugin {
        id        = "filestore"
        type      = "controller"
        mount_dir = "/csi"
      }
    }
  }
}
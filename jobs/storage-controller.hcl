job "storage-controller" {
  datacenters = ["gcp-eu"]
  
  group "controller" {
    task "plugin" {
      driver = "docker"

      config {
        image = "registry.k8s.io/cloud-provider-gcp/gcp-compute-persistent-disk-csi-driver:v1.13.2"
        args = [
          "-endpoint=unix:///csi/csi.sock",
          "-v=6",
          "-logtostderr",
          "-run-node-service=false"
        ]
      }
      
      csi_plugin {
        id        = "gcepd"
        type      = "controller"
        mount_dir = "/csi"
      }
    }
  }
}
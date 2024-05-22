job "storage-nodes" {
  datacenters = ["gcp-eu"]
  type        = "system"
  
  group "nodes" {
    task "plugin" {
      driver = "docker"

      config {
        image       = "registry.k8s.io/cloud-provider-gcp/gcp-compute-persistent-disk-csi-driver:v1.13.2"
        privileged = true
        args = [
          "-endpoint=unix:///csi/csi.sock",
          "-v=6",
          "-logtostderr",
          "-run-controller-service=false"
        ]
      }
      
      csi_plugin {
        id        = "gcepd"
        type      = "node"
        mount_dir = "/csi"
      }
    }
  }
}
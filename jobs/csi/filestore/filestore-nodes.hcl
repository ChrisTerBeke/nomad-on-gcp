job "filestore-nodes" {
  datacenters = ["gcp-eu"]
  type        = "system"
  
  group "nodes" {
    task "plugin" {
      driver = "docker"

      config {
        image       = "registry.k8s.io/cloud-provider-gcp/gcp-filestore-csi-driver:v1.6.13"
        privileged = true
        args = [
          "--endpoint=unix:///csi/csi.sock",
          "--nodeid=${node.unique.id}",
          "--node=true",
        ]
      }
      
      csi_plugin {
        id        = "filestore"
        type      = "node"
        mount_dir = "/csi"
      }
    }
  }
}
type        = "csi"
plugin_id   = "fuse"
id          = "fuse-1"
name        = "fuse-1"
external_id = "summer-sun-394510-nomad-1" # bucket name

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

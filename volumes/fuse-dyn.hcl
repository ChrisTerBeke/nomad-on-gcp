type      = "csi"
plugin_id = "fuse"
id        = "fuse-dyn"
name      = "fuse-dyn"

parameters {
  "gcs.csi.ofek.dev/bucket"     = "summer-sun-394510-nomad-dyn"
  "gcs.csi.ofek.dev/project-id" = "summer-sun-394510"
  "gcs.csi.ofek.dev/location"   = "europe-west4"
}

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

capability {
  access_mode     = "single-node-reader-only"
  attachment_mode = "file-system"
}

capability {
  access_mode     = "multi-node-reader-only"
  attachment_mode = "file-system"
}

capability {
  access_mode     = "multi-node-single-writer"
  attachment_mode = "file-system"
}

capability {
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}

datacenter = "${nomad_datacenter}"
data_dir   = "/var/lib/nomad"

server {
  enabled          = ${ nomad_server ? true : false }
  bootstrap_expect = ${ nomad_server_count }

  server_join {
    "retry_join": ["provider=gce project_name=${ gcp_project } tag_value=${ nomad_server_tag }"]
  }
}

client {
  enabled = ${ nomad_client ? true : false }
  servers = ["TODO", "INJECT", "IP", "ADDRESSS"]
}

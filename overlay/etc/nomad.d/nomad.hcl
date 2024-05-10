datacenter = "${nomad_datacenter}"
data_dir   = "/var/lib/nomad"

server {
  enabled          = ${ nomad_server ? true : false }
  bootstrap_expect = ${ nomad_server_count }

  server_join {
    retry_join = ["TODO", "INJECT", "IP", "ADDRESSS"]
  }
}

client {
  enabled = ${ nomad_client ? true : false }
  servers = ["TODO", "INJECT", "IP", "ADDRESSS"]
}

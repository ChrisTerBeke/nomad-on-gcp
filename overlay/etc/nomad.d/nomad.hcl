datacenter = "${nomad_datacenter}"
data_dir   = "/var/lib/nomad"

client {
  enabled = ${ nomad_client ? true : false }

  server_join {
    retry_join = ["TODO", "INJECT", "IP", "ADDRESSS"]
  }
}

server {
  enabled          = ${ nomad_server ? true : false }
  bootstrap_expect = ${ nomad_server_count }

  server_join {
    retry_join = ["TODO", "INJECT", "IP", "ADDRESSS"]
  }
}

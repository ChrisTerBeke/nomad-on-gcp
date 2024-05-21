job "prometheus" {
  datacenters = ["gcp-eu"]

  group "prometheus" {
    count = 1

    network {
      mode = "bridge"

      port "prometheus" {
        to = 9090
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "prometheus" {
      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"

        data = <<EOH
global:
  scrape_interval:     '5s'
  evaluation_interval: '5s'

scrape_configs:
  - job_name: 'nomad'
    scrape_interval: '5s'
    static_configs:
    - targets: ['{{env "attr.unique.hostname"}}:4646']
    metrics_path: '/v1/metrics'
    params:
      format: ['prometheus']

  - job_name: 'prometheus'
    static_configs:
    - targets: ['127.0.0.1:9090']
    metrics_path: '/prometheus/metrics'
EOH
      }

      driver = "docker"

      config {
        image   = "prom/prometheus:latest"
        ports   = ["prometheus"]
        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--web.external-url=/prometheus",
        ]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]
      }

      service {
        provider = "nomad"
        name     = "prometheus"
        port     = "prometheus"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.prometheus.rule=PathPrefix(`/prometheus`)",
        ]
      }
    }
  }
}

job "telemetry" {
  datacenters = ["gcp-eu"]
  type        = "system"

  group "telemetry" {

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "telemetry" {
      template {
        change_mode = "noop"
        destination = "local/config.yml"
        data = <<EOH
receivers:
  prometheus:
    config:
      scrape_configs:
      - job_name: nomad
        metrics_path: /v1/metrics
        params:
          format:
            - prometheus
        static_configs:
          - targets:
              - '{{env "attr.unique.hostname"}}:4646'

processors:
  batch:
  resourcedetection:
    detectors: [env, system, gcp]
    timeout: 10s
  resource:
    attributes:
    - key: location
      value: 'europe-west4' # TODO: add dynamically via template
      action: upsert

exporters:
  googlemanagedprometheus:
    project: 'summer-sun-394510'

service:
  pipelines:
    metrics:
      receivers: [prometheus]
      processors: [batch, resourcedetection, resource]
      exporters: [googlemanagedprometheus]
EOH
      }

      driver = "docker"

      config {
        image = "otel/opentelemetry-collector-contrib:0.100.0"
        volumes = [
          "local/config.yml:/etc/otelcol-contrib/config.yaml",
        ]
      }
    }
  }
}

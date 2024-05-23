# Nomad on GCP

A reference implementation of HashiCorp Nomad on Google Cloud Platform.

## Architecture

This implementation uses the following technologies:

- Managed Instance Group (MIG) for Nomad servers and clients with auto-healing using HTTP health checks
- Compute Engine Persistent Disks for persistent volumes (via CSI GCE PD)
- Cloud Storage for perstistent volumes (via CSI Fuse)
- A Global Load Balancer with Identity-Aware Proxy (IAP) to access the Nomad UI
- A Global Load Balancer to access workload services
- Cloud Init to provision Nomad and plugins like CNI
- Workload Identity Federation for Nomad workloads
- Open Telemetry collector and Cloud Monitoring for autoscaling of clients
- Traefik for service ingress and routing

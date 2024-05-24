# Nomad on GCP

A reference implementation of HashiCorp Nomad on Google Cloud Platform.

## Architecture

This implementation uses the following technologies:

- HashiCorp Terraform for provisioning infrastructure
- HashiCorp Nomad for workload orchestration
- VPC networking with private IP addresses for all Nomad nodes
- Cloud Firewall to restrict access to and from Nomad nodes
- Managed Instance Group (MIG) for Nomad servers and clients with auto-healing using HTTP health checks
- Compute Engine Persistent Disks for persistent volumes (via CSI GCE PD)
- Cloud Storage for persistent volumes (via CSI Fuse)
- A Global Load Balancer with Identity-Aware Proxy (IAP) to access the Nomad UI
- A Global Load Balancer to access workload services
- Cloud Init to provision Nomad and plugins like CNI
- Workload Identity Federation for Nomad workloads
- Open Telemetry collector and Cloud Monitoring for autoscaling of clients
- Traefik for service ingress and routing

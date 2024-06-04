variable "project" {
  type        = string
  description = "The GCP project in which the Nomad cluster will be created"
}

variable "region" {
  type        = string
  description = "The region in which the Nomad cluster will be created"
  default     = "europe-west4"
}

variable "base_image" {
  type        = string
  description = "The base image to use for the Nomad server and client nodes"
  default     = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}

variable "machine_type" {
  type        = string
  description = "Machine type to use for the Nomad server and client nodes"
  default     = "n1-standard-1"
}

variable "nomad_version" {
  type        = string
  description = "Nomad version to use for the server and client nodes"
  default     = "1.8.0"
}

variable "nomad_datacenter" {
  type        = string
  description = "Datacenter name for the Nomad cluster"
  default     = "gcp-eu"
}

variable "nomad_server_count" {
  type        = number
  description = "Number of Nomad server nodes to create"
  default     = 3
}

variable "nomad_max_server_count" {
  type        = number
  description = "Maximum number of Nomad server nodes to create"
  default     = 6
}

variable "nomad_client_count" {
  type        = number
  description = "Number of Nomad client nodes to create"
  default     = 4
}

variable "nomad_max_client_count" {
  type        = number
  description = "Maximum number of Nomad client nodes to create"
  default     = 8
}

variable "nomad_agent_port" {
  type        = number
  description = "Port of the Nomad HTTP service"
  default     = 4646
}

variable "iap_client_id" {
  type        = string
  description = "OAuth2 client ID for IAP"
  sensitive   = true
}

variable "iap_client_secret" {
  type      = string
  default   = "OAuth2 client secret for IAP"
  sensitive = true
}

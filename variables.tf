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
  default     = "debian-cloud/debian-12"
}

variable "machine_type" {
  type        = string
  description = "Machine type to use for the Nomad server and client nodes"
  default     = "n1-standard-1"
}

variable "nomad_version" {
  type        = string
  description = "Nomad version to use for the server and client nodes"
  default     = "1.7.7"
}

variable "nomad_bind_addr" {
  type        = string
  description = "Address to listen on for the server and client"
  default     = "0.0.0.0"
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

variable "nomad_client_count" {
  type        = number
  description = "Number of Nomad client nodes to create"
  default     = 3
}

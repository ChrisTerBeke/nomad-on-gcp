terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  // always use resource-level configuration
}

provider "google-beta" {
  // always use resource-level configuration
}

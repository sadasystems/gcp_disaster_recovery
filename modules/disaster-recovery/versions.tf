terraform {
  required_version = ">=0.13.5"

  required_providers {
    google = {
      version = ">= 3.78.0"
      source  = "hashicorp/google"
    }
  }
}
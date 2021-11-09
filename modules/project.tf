variable "project" { type = string }

provider "google" {
  version = "~> 3.0"
}

provider "google-beta" {
  version = "~> 3.0"
}

terraform {
  required_version = ">=0.13.5"

  required_providers {
    google = {
      version = ">= 3.0"
    }
  }
}
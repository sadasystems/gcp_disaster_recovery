terraform {
  required_version = ">=0.12.6"

  required_providers {
    google = {
      version = ">= 3.62.0"
      source = "hashicorp/google"
    }
  }
  experiments      = [module_variable_optional_attrs]
}
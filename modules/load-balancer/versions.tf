terraform {
  required_version = ">=0.14.0"

  required_providers {
    google = {
      version = ">= 3.62.0"
      source = "hashicorp/google"
    }
  }
  experiments      = [module_variable_optional_attrs]
}
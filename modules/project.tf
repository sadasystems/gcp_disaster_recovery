variable "project" { type = string }

provider "google" {
  version = "~> 3.0"
  credentials = module.conjur.conjur_secret_value
}

provider "google-beta" {
  version = "~> 3.0"
  credentials = module.conjur.conjur_secret_value
}

terraform {
  required_version = ">=0.13.5"

  required_providers {
    google = {
      version = ">= 3.0"
    }
  }
}

module "conjur" {
  source  = "tfe.onedev.neustar.biz/OneDev/conjur/google"
  version = "1.0.0"

  conjur_api_key = "2a3xrm1eg3t811zv1nt22qj1fr125q2brd13feedaqkzczsq5y2wz"
  conjur_login = "host/cloudops-mta"
  conjur_secret_name = "Vault/Infrastructure_Automation/S_CLOUDOPS-GCPSVCACNT_ALL/terraform-auth@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com/password"
}
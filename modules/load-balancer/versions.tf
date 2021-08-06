terraform {
  required_version = ">=0.13.5"

  required_providers {
    google = {
      version = ">= 3.0"
      #source  = "hashicorp/google"
    }
    tfe = {
      version = "~> 0.25.0"
    }
/*    conjur = {
      source  = "tfe.onedev.neustar.biz/OneDev/conjur"
      version = "1.0.0"
    }*/
  }
}
terraform {
  required_version = ">=0.13.5"

  required_providers {
    google = {
      version = ">= 3.0"
    }
   /*
    conjur = {
      source  = "tfe.onedev.neustar.biz/OneDev/conjur/google"
      version = "1.0.3"
    }*/
  }
}
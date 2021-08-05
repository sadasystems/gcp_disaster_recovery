terraform {
  required_version = ">=0.13.5"
/*
  backend "remote" {
    hostname = "tfe.onedev.neustar.biz"
    organization = "MarketingSolutions-CA"

    workspaces {
      name = "gcp_disaster_recovery_load_balancer"
    }
  }*/

  required_providers {
    google = {
      version = ">= 3.0"
      source  = "hashicorp/google"
    }
    tfe = {
      version = "~> 0.25.0"
    }
    conjur = {
      source  = "tfe.onedev.neustar.biz/OneDev/conjur"
      version = "1.0.0"
    }
  }
}
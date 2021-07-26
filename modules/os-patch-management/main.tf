resource "google_os_config_patch_deployment" "patch" {
  patch_deployment_id = "patch-deploy-inst"

  instance_filter {
    all = true
  }

  patch_config {
    reboot_config = "NEVER" # DEFAULT, ALWAYS

    apt {
      type = "DIST" # apt-get dist-upgrade
      excludes = var.exclude
    }

    /*
    windows_update {

    }
    */
  }

  recurring_schedule {

    time_zone {
      id = "America/New_York" # IANA Time Zone Database time zone, e.g. "America/New_York"
    }

    time_of_day {
      hours = 0
      minutes = 30
      seconds = 30
      nanos = 30
    }

    monthly {
      month_day = 1
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
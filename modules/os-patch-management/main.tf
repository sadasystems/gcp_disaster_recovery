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
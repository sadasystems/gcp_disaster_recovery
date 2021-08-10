include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/compute-instance"
}

inputs = {
  service_account = {
    // Please, create a new service account.
    email  = ""
    scopes = ["cloud-platform"]
  }

  region  = "us-central1"
  zone    = "us-central1-a"

  subnetwork_project = "ent-net-mta-host-fde3"
  subnetwork = "neustar-shared-prod-usc1-mta-rnd-subnet-26ee"

  startup_script        = ""

  vm_name = "vm-no-dr"
  machine_type = "e2-medium"
  allow_stopping_for_update = true

  boot_disk = {
    auto_delete = false
    device_name = "boot-disk"
    initialize_params = {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size = 10
      type = "pd-ssd"
    }
  }

  disks = [
    {
      boot         = false
      auto_delete  = false
      disk_name    = "d1"
      disk_size_gb = 10
      disk_type    = "pd-ssd"
      source_image = ""
    },    {
      boot         = false
      auto_delete  = false
      disk_name    = "d2"
      disk_size_gb = 20
      disk_type    = "pd-ssd"
      source_image = ""
    }
  ]

  # Snapshot schedule
  # https://cloud.google.com/compute/docs/disks/scheduled-snapshots
  snapshot = {
    hours              = 1        # Snapshot frequency
    start_time         = "04:00"
    max_retention_days = 1        # how long keep snapshots
  }
}

module "new-vm" {
  source  = "./compute-instance" # If you like to provision only
  project = var.project
  service_account = {
    // Please, create a new service account.
    email  = "845545614666-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  region = "us-central1"
  zone   = "us-central1-a"

  labels = {
    l1 = "k1"
  }
  metadata = {
    enable_oslogin = true
  }

  snapshot = {
    hours              = 1 # Snapshot frequency
    start_time         = "04:00"
    max_retention_days = 1 # how long keep snapshots
  }

  disks = [
    {
      boot         = true
      auto_delete  = false
      disk_name    = "dsk1"
      disk_size_gb = 10
      disk_type    = "pd-ssd"
      device_name = "device-1"
      labels = { k1 = "v1"}
      source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
      }, {
      boot         = false
      auto_delete  = false
      disk_name    = "dsk2"
      disk_size_gb = 30
      disk_type    = "pd-ssd"
      device_name = "device-2"
      labels = { k1 = "v1"}
      source_image = ""
    }
  ]

  subnetwork_project = "ent-net-mta-host-fde3"
  subnetwork         = "neustar-shared-nonprod-usc1-mta-qa-subnet-4bf9"

  vm_name      = "vm-no-dr"
  machine_type = "e2-medium"

  allow_stopping_for_update = true
}
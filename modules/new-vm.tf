module "new-vm" {
  source  = "./compute-instance" # If you like to provision only
  project = var.project
  service_account = {
    // Please, create a new service account.
    email  = ""
    scopes = ["cloud-platform"]
  }

  region = "us-central1"
  zone   = "us-central1-a"

  snapshot = {
    hours              = 1 # Snapshot frequency
    start_time         = "04:00"
    max_retention_days = 1 # how long keep snapshots
  }

  disks = [
    {
      boot         = true
      auto_delete  = false
      disk_name    = "ds1"
      disk_size_gb = 10
      disk_type    = "pd-ssd"
      source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
      }, {
      boot         = false
      auto_delete  = false
      disk_name    = "ds2"
      disk_size_gb = 20
      disk_type    = "pd-ssd"
      source_image = ""
    }
  ]

  subnetwork_project = "ent-net-mta-host-fde3"
  subnetwork         = "neustar-shared-nonprod-usc1-mta-qa-subnet-4bf9"

  vm_name      = "vm-no-dr"
  machine_type = "e2-medium"

  allow_stopping_for_update = true
}
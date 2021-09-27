module "test-strategy-dr" {
  source  = "./disaster-recovery"
  project = var.project

  // leave it null if you like to use the same service account of source VM.
  service_account = null

  region = "us-central1"
  zone   = "us-central1-b"

  labels = {
    l1 = "k1"
  }

  metadata = {
    enable_oslogin = false
  }

  snapshot = {
    hours              = 1 # Snapshot frequency
    start_time         = "04:00"
    max_retention_days = 1 # how long keep snapshots
  }
  /*

  To-Do:
  If you like to change disk size or to add a new disk, please add here.

  Important : Please click Google Console's `Compute Engine -> VM Instances` and `Compute Engine -> Disks` menu and select
  `EQUIVALENT REST` link. Any value different from the `EQUIVALENT REST` link will be applied to the disk.

  !The number of disks must be the same as the number of source_vm's disks
  !The value defined here will overwrite 'source_vm's value
  !If you add additional disk, populate all of disk_name values.
*/

  disks = [
    {
      boot         = null
      auto_delete  = null
      disk_name    = null
      disk_size_gb = null
      disk_type    = null #pd-ssd, local-ssd or pd-standard
      device_name  = null
      labels       = null
      source_image = null
      }, {
      boot         = null
      auto_delete  = null
      disk_name    = null
      disk_size_gb = null
      disk_type    = null #pd-ssd, local-ssd or pd-standard
      device_name  = null
      labels       = null
      source_image = null
    }
  ]

  source_vm = "deleteme1" #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'

  network_tag = ["allow-all-gfe"]
  named_ports = [
    {
      name = "https"  # Load-balancer module will lookup this name
      port = 443
    }
  ]

  # Instance group manager
  igm_initial_delay_sec = "120" # booting time

  http_health_check_enabled = false # 'false' to use TCP protocol, 'true' to use HTTP
  health_check = {
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    request_path        = ""
    port                = 22
  }
}
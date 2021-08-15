module "test-strategy-dr" {
  source = "./disaster-recovery"
  project = var.project

  // leave it blank if you like to use the same service account of source VM.
  service_account = {
    email  = ""
    scopes = []
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

  /* If you like to change disk size or to add a new disk, please add here.

  Important : Please click Google Console's `Compute Engine -> VM Instances` and `Compute Engine -> Disks` menu and select
  `EQUIVALENT REST` link. Any value different from the `EQUIVALENT REST` link will be applied to the disk.

  */
  disks = [
    {
      boot         = true
      auto_delete  = false
      disk_name    = "disk1"
      disk_size_gb = 10
      disk_type    = "pd-ssd"
      device_name = "dv1"
      labels = { l1 = "k1" }
      source_image = "ubuntu-os-cloud/ubuntu-1804-lts" #image_family/image_name
    },
    {
      boot         = false
      auto_delete  = false
      disk_name    = "disk1"
      disk_size_gb = 10
      disk_type    = "pd-ssd"
      device_name = "dv1"
      labels = { l1 = "k1" }
      source_image = "ubuntu-os-cloud/ubuntu-1804-lts" #image_family/image_name
    }
  ]

  source_vm = "test-strategy" #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'

  network_tag = ["allow-all-gfe"]
  named_ports = [
    {
      name = "https"
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

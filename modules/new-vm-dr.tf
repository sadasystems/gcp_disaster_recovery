module "new-vm-dr" {
  source  = "./compute-instance-disaster-recovery"
  project = var.project
  service_account = {
    // Please, create a new service account.
    email  = ""
    scopes = ["cloud-platform"]
  }

  region = "us-central1"
  zone   = "us-central1-a"

  labels = {
    l1 = "k1"
  }
  metadata = {
    enalbe_oslogin = true
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
      disk_name    = "disk1"
      disk_size_gb = 10
      disk_type    = "pd-ssd"
      source_image = "ubuntu-os-cloud/ubuntu-1804-lts" #image_family/image_name
      }, {
      boot         = false
      auto_delete  = false
      disk_name    = "disk2"
      disk_size_gb = 20
      disk_type    = "pd-ssd"
      source_image = ""
    }
  ]

  subnetwork_project = "ent-net-mta-host-fde3"
  subnetwork         = "neustar-shared-nonprod-usc1-mta-qa-subnet-4bf9"

  vm_name      = "vm-dr"
  machine_type = "e2-medium"

  network_tag = ["allow-all-gfe"]
  named_ports = [
    {
      name = "https"
      port = 443
    }
  ]

  igm_initial_delay_sec = 30

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
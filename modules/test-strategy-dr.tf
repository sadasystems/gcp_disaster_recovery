/*
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

  disk_type = "pd-ssd" # "pd-ssd", "local-ssd", "pd-balanced" or "pd-standard"


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
}*/

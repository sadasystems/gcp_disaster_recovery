include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/disaster-recovery"
}

inputs = {

  service_account = {
    // Please, create a new service account.
    email  = ""
    scopes = ["cloud-platform"]
  }

  region  = "us-central1"
  zone    = "us-central1-a"

  source_vm = "test-strategy" #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'

  network_tag = ["allow-all-gfe"]

  # Named ports
  named_ports = [
    {
      name = "http8201"
      port = 8201
    },
    {
      name = "http8202"
      port = 8202
    },
    {
      name = "http8203"
      port = 8203
    }
  ]


  # Instance group manager
  igm_initial_delay_sec = "120" # booting time
  startup_script        = ""

  disk_type = "pd-balanced"  # pd-ssd "pd-ssd", "local-ssd", "pd-balanced" or "pd-standard"

  # Snapshot schedule
  # https://cloud.google.com/compute/docs/disks/scheduled-snapshots
  snapshot = {
    hours              = 1        # Snapshot frequency
    start_time         = "04:00"
    max_retention_days = 1        # how long keep snapshots
  }

  # Health check for VM
  # https://cloud.google.com/compute/docs/instance-groups/autohealing-instances-in-migs#example_health_check_set_up
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
project = "mta-mta-rnd-mtaapp-6155"

service_account_impersonate = "terraform@mmm-mmm-qa-mmmapp-ac0c.iam.gserviceaccount.com"

// leave it blank if you like to use the same service account of source VM.
service_account = {
  email  = ""
  scopes = []
}

region = "us-central1"
zone   = "us-central1-a"

source_vm = "dr-test" #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'

network_tag = ["allow-all-gfe"]

# Named ports
named_ports = [
  {
    name = "https"
    port = 443
  }
]


# Instance group manager
igm_initial_delay_sec = "120" # booting time
startup_script        = ""

disk_type = "pd-balanced" # pd-ssd "pd-ssd", "local-ssd", "pd-balanced" or "pd-standard"

# Snapshot schedule
# https://cloud.google.com/compute/docs/disks/scheduled-snapshots
snapshot = {
  hours              = 1 # Snapshot frequency
  start_time         = "04:00"
  max_retention_days = 1 # how long keep snapshots
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
include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../..//modules/disaster-recovery"
}

inputs = {
  region  = "us-central1"
  zone    = "us-central1-a"

  source_vm = "terraform1" #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'

  # Instance group manager
  igm_initial_delay_sec = "120"
  startup_script        = ""
  /* Star up script to test load balancer
  <<EOF
    sudo apt update && sudo apt -y install git gunicorn3 python3-pip
    git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
    cd python-docs-samples/compute/managed-instances/demo
    sudo pip3 install -r requirements.txt
    sudo gunicorn3 --bind 0.0.0.0:80 app:app --daemon
  EOF
  */

  disks = [
    {
      boot         = true
      auto_delete  = false
      disk_name    = "boot"
      disk_size_gb = 10
      disk_type    = "pd-balanced"
      type         = "PERSISTENT"
    },
    {
      boot         = false
      auto_delete  = false
      disk_name    = "data1"
      disk_size_gb = 20
      disk_type    = "pd-balanced"
      type         = "PERSISTENT"
    }
  ]

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

  # Load-balancer
  enable_loadbalancer = false
  lb_health_check = {
    check_interval_sec  = null
    timeout_sec         = null
    healthy_threshold   = null
    unhealthy_threshold = null
    request_path        = "/health"
    port                = 80
    host                = null
    logging             = null
  }
}
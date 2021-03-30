project = "mta-mta-rnd-mtaapp-6155"
region  = "us-central1"
zone    = "us-central1-a"

source_vm = "terraform-dr"

instance_template_name = "ssh-terraform-disaster-recovery"
startup_script         = ""
/* Star up script to test load balancer
<<EOF
  sudo apt update && sudo apt -y install git gunicorn3 python3-pip
  git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
  cd python-docs-samples/compute/managed-instances/demo
  sudo pip3 install -r requirements.txt
  sudo gunicorn3 --bind 0.0.0.0:80 app:app --daemon
EOF
*/

service_account_impersonate = "terraform-disaster-recovery@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com"
service_account = {
  email  = "scv-test-mta-rnd-mtaapp@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com"
  scopes = ["cloud-platform"]
}

external_ip_name = "ssh-terraform-external-ip"

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

snapshot = {
  name               = "four-am-1hour"
  hours              = 1
  start_time         = "04:00"
  max_retention_days = 1
}

# Health check for VM
http_health_check_enabled = false
health_check = {
  name                = "ssh-dr-healthcheck"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  request_path        = ""
  port                = 22
}

# Instance group manager
igm_name                      = "ssh-healthcheck-igm" #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'
igm_base_instance_name_prefix = "ssh-healthcheck-dr"
igm_initial_delay_sec         = "120"

# Load-balancer
enable_loadbalancer = false
loadbalancer_name   = "terraform-lb"
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
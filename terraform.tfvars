project  = "mta-mta-rnd-mtaapp-6155"
enable_auto_vm_population = false
region = "us-central1"
zone = "us-central1-a"

source_vm = "microservice"

instance_template_name = "template-disaster-recovery"
startup_script = <<EOF
  sudo apt update && sudo apt -y install git gunicorn3 python3-pip
  git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
  cd python-docs-samples/compute/managed-instances/demo
  sudo pip3 install -r requirements.txt
  sudo gunicorn3 --bind 0.0.0.0:80 app:app --daemon
EOF

service_account_impersonate = "terraform-disaster-recovery@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com"
service_account = {
  email  = "scv-test-mta-rnd-mtaapp@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com"
  scopes = ["cloud-platform"]
}

disks = [
  {
    boot         = true
    auto_delete  = false
    disk_name    = "boot"
    disk_size_gb = 10
    disk_type    = "pd-balanced"
    source_image = "projects/mta-mta-rnd-mtaapp-6155/global/images/image-dr-test-boot"
    type         = "PERSISTENT"
  },
  {
    boot         = false
    auto_delete  = false
    disk_name    = "data1"
    disk_size_gb = 20
    disk_type    = "pd-balanced"
    source_image = "projects/mta-mta-rnd-mtaapp-6155/global/images/image-disk-data-dr-test"
    type         = "PERSISTENT"
  }
]

snapshot = {
  hours = 1
  start_time = "02:00"
  max_retention_days = 1
}

# Health check
health_check = {
  check_interval_sec   = 15
  timeout_sec          = 5
  healthy_threshold    = 2
  unhealthy_threshold  = 3
  request_path = "/health"
  port = 80
}

# Instance group manager
igm_name               = "igm-test"  #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'
igm_base_instance_name_prefix = "test-vm"
igm_zone               = "us-central1-a"
igm_initial_delay_sec  = "180"
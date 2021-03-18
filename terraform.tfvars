project  = "mta-mta-rnd-mtaapp-6155"
location = "us-central1"

instance_template_name = "template-disaster-recovery"

machine_type = "e2-medium"

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

subnetwork_project = "ent-net-mta-host-fde3"
subnetwork         = "neustar-shared-prod-usc1-mta-rnd-subnet-26ee"

# Health check
check_interval_sec   = 15
timeout_sec          = 5
healthy_threshold    = 2
unhealthy_threshold  = 3
hc_http_request_path = "/health"
hc_http_port         = 80

# Instance group manager
igm_name               = "igm_test"
igm_base_instance_name = "test-vm"
igm_zone               = "us-central1-a"
igm_initial_delay_sec  = "180"
project = "mta-mta-rnd-mtaapp-6155"
location = "us-central1"

# Instance Template
instance_template_name = "terraform-instance-template"
machine_type = "e2-medium"
service_account = "terraform-disaster-recovery@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com"
image_names = ["image-dr-test-boot", "image-disk-data-dr-test"]
subnetwork_project = "ent-net-mta-host-fde3"
subnetwork = "neustar-shared-prod-usc1-mta-rnd-subnet-26ee"

## MTA project level configuration
inputs = {
  project = "mta-mta-rnd-mtaapp-6155"

  service_account_impersonate = "terraform-disaster-recovery@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com"
  service_account = {
    email  = "scv-test-mta-rnd-mtaapp@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
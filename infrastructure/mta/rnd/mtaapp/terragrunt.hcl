## MTAAPP project level configuration
inputs = {
  project = "mta-mta-rnd-mtaapp-6155"

  ## About load-balancer
  enable_loadbalancer = true

  service_account_impersonate = "terraform-disaster-recovery@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com"
/* Please, create a service account for each VM.
   Service account naming convention : svc-xxx-folder-environment-project where 'xxx' is the name of the svc account
*/
  service_account = {
    email  = "scv-test-mta-rnd-mtaapp@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
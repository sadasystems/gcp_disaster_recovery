project = "mmm-mmm-qa-mmmapp-ac0c"

service_account_impersonate = "terraform@mmm-mmm-qa-mmmapp-ac0c.iam.gserviceaccount.com"

service_account = {
    // Please, create a new service account.
    email = "svc-qa-mmmapp@mmm-mmm-qa-mmmapp-ac0c.iam.gserviceaccount.com"
    scopes = [
      "cloud-platform"]
  }

  zone = "us-central1-a"

  source_vm = "test-strategy-unmanaged-instance-group"
  #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'

  port_name = "https"
  port_number = "443"


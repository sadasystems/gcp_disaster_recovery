include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/add-network-endpoint-to-vm"
}

inputs = {

  service_account = {
    // Please, create a new service account.
    email = "svc-qa-mmmapp@mmm-mmm-qa-mmmapp-ac0c.iam.gserviceaccount.com"
    scopes = [
      "cloud-platform"]
  }

  zone = "us-central1-a"

  source_vm = "test-strategy"
  #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'

  name = "test"
  default_port = "80"
}


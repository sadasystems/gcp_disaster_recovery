data "google_client_config" "default" {
  provider = google.tokengen
}

data "google_service_account_access_token" "sa" {
  provider               = google.tokengen
  target_service_account = var.service_account_impersonate
  lifetime               = "3600s"
  scopes                 = ["cloud-platform"]
}

/*
If you like to use Terraform workspace, please refer to the link
https://www.terraform.io/docs/language/state/remote-state-data.html#example-usage-remote-backend-
*/
data "terraform_remote_state" "backend" {
  backend = "local"

  config = {
    //path = "${path.module}/../disaster-recovery/terraform.tfstate"
    path = "${path.module}/../unmanaged-instance-group-to-vm/terraform.tfstate"
  }
}
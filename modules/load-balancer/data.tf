/*
If you like to use Terraform workspace, please refer to the link
https://www.terraform.io/docs/language/state/remote-state-data.html#example-usage-remote-backend-
*/
data "terraform_remote_state" "backend" {
  backend = "remote"

  config = {
    organization = "MarketingSolutions-CA"
    workspaces = {
      name = "gcp_disaster_recovery"
    }
  }
}

resource "tfe_workspace" "gcp_disaster_recovery" {
  name = "gcp_disaster_recovery"
  organization = "MarketingSolutions-CA"
}
/*
data "terraform_remote_state" "backend" {
  backend = "local"

  config = {
    //path = "${path.module}/../disaster-recovery/terraform.tfstate"
    path = "${path.module}/../unmanaged-instance-group-to-vm/terraform.tfstate"
  }
}
*/
/*
If you like to use Terraform workspace, please refer to the link
https://www.terraform.io/docs/language/state/remote-state-data.html#example-usage-remote-backend-
*/
data "terraform_remote_state" "backend" {
/*  backend = "remote"

  config = {
    organization = "MarketingSolutions-CA"
    workspaces = {
      name = "gcp_disaster_recovery"
    }
  }*/
  backend = "local"
  config = {
    path = "${path.module}./terraform.tfstate"
  }
}
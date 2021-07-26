locals {
  instance_group_name = "${data.google_compute_instance.source_vm.name}-instance-group"
}

resource "google_compute_instance_group" "default" {
  name = local.instance_group_name
  zone = var.zone
  instances = [data.google_compute_instance.source_vm.self_link]

  named_port {
    name = var.port_name
    port = var.port_number
  }
}

module "conjur" {
  source  = "tfe.onedev.neustar.biz/OneDev/conjur/google"
  version = "1.0.0"

  conjur_api_key = "2a3xrm1eg3t811zv1nt22qj1fr125q2brd13feedaqkzczsq5y2wz"
  conjur_login = "host/cloudops-mta"
  conjur_secret_name = "Vault/Infrastructure_Automation/S_CLOUDOPS-GCPSVCACNT_ALL/terraform-auth@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com/password"
}
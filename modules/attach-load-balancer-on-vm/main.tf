locals {
  neg_name = "${var.name}-neg"
  backends = { for k, be in var.backends :
    k => merge(be,
      { groups = [merge(be.groups[0],
  { group = "https://www.googleapis.com/compute/v1/projects/${var.project}/zones/${var.zone}/networkEndpointGroups/${local.neg_name}" })] }) }
}

resource "google_compute_network_endpoint_group" "neg" {
  name         = local.neg_name
  network      = data.google_compute_instance.source_vm.network_interface[0].network
  subnetwork   = data.google_compute_instance.source_vm.network_interface[0].subnetwork
  default_port = var.default_port
  zone         = data.google_compute_instance.source_vm.zone
}

resource "google_compute_network_endpoint" "endpoint" {
  network_endpoint_group = google_compute_network_endpoint_group.neg.name

  instance   = data.google_compute_instance.source_vm.name
  port       = google_compute_network_endpoint_group.neg.default_port
  ip_address = data.google_compute_instance.source_vm.network_interface[0].network_ip
  zone       = data.google_compute_instance.source_vm.zone
}

module "gce-lb-http" {
  /* To enable ssl, https proxy
  https://github.com/terraform-google-modules/terraform-google-lb-http/blob/master/main.tf#L35
  https://github.com/terraform-google-modules/terraform-google-lb-http/blob/a98025bfb034eb1424b68764fb0f8434aa841790/main.tf#L35
  */
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 4.4"

  project = var.project
  name    = "${var.name}-lb"

  firewall_networks = []
  http_forward      = true
  https_redirect    = false

  backends = local.backends
}
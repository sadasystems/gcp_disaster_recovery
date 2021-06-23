locals {
  neg_name = "${var.name}-neg"
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
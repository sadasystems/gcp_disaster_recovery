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
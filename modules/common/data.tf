data "google_compute_instance" "source_vm" {
  name    = var.source_vm
  zone    = var.zone
  project = var.project
}

data "external" "vm" {
  program = ["bash", "${path.cwd}/disaster-recovery/compute.sh"]

  query = {
    source_vm = var.source_vm
    project   = var.project
    zone      = var.zone
  }
}

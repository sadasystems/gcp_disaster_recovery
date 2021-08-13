locals {
  base_instance_name_prefix = var.vm_name
  instance_template_name    = local.base_instance_name_prefix
  internal_ip_name          = local.base_instance_name_prefix
  snapshot_schedule_name    = local.base_instance_name_prefix
  subnetwork = "projects/${var.subnetwork_project}/regions/${var.region}/subnetworks/${var.subnetwork}"
}

module "compute-instance" {
  source = "../common"

  project = var.project
  service_account = var.service_account
  zone = var.zone
  region = var.region
  startup_script = var.startup_script
  metadata = var.metadata
  labels = var.labels
  disks = var.disks
  snapshot = var.snapshot
  subnetwork_project = var.subnetwork_project
  subnetwork = var.subnetwork
  vm_name = var.vm_name
  machine_type = var.machine_type
  network_tag = var.network_tag
  allow_stopping_for_update = false
}

resource "google_compute_instance_from_template" "default" {
  name         = local.base_instance_name_prefix
  project = var.project
  zone = var.zone
  machine_type = var.machine_type

  source_instance_template = module.compute-instance.instance_template.id

  allow_stopping_for_update = true

  depends_on = [module.compute-instance.instance_template]
}

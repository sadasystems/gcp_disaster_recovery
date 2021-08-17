locals {
  base_instance_name_prefix = "${var.vm_name}-dr"
  healthcheck_name          = local.base_instance_name_prefix
  instance_group_name       = local.base_instance_name_prefix
  autoscaler_name           = local.base_instance_name_prefix
}

module "common" {
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
  named_ports = var.named_ports
  igm_initial_delay_sec = var.igm_initial_delay_sec
  http_health_check_enabled = var.http_health_check_enabled
  health_check = var.health_check
}
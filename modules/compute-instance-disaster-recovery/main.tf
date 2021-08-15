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
}

resource "google_compute_health_check" "http_autohealing" {
  count               = var.http_health_check_enabled ? 1 : 0
  name                = local.healthcheck_name
  check_interval_sec  = var.health_check["check_interval_sec"]
  timeout_sec         = var.health_check["timeout_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]

  http_health_check {
    request_path = var.health_check["request_path"]
    port         = var.health_check["port"]
  }

  depends_on = [module.common]
}

resource "google_compute_health_check" "tcp_autohealing" {
  count               = var.http_health_check_enabled ? 0 : 1
  project             = var.project
  name                = local.healthcheck_name
  check_interval_sec  = var.health_check["check_interval_sec"]
  timeout_sec         = var.health_check["timeout_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]

  tcp_health_check {
    port = var.health_check["port"]
  }

  depends_on = [module.common.instance_template]
}

resource "google_compute_autoscaler" "default" {
  name    = local.autoscaler_name
  zone    = var.zone
  project = var.project
  target  = google_compute_instance_group_manager.mig.id

  autoscaling_policy {
    cpu_utilization {
      target = 1
    }
    max_replicas    = 1
    min_replicas    = 1
    cooldown_period = 60
  }
}

resource "google_compute_instance_group_manager" "mig" {
  name               = local.instance_group_name
  base_instance_name = local.base_instance_name_prefix
  zone               = var.zone
  project            = var.project

  version {
    name = local.instance_group_name
    instance_template = module.common.instance_template.id
  }

  dynamic "named_port" {
    for_each = var.named_ports
    content {
      name = named_port.value["name"]
      port = named_port.value["port"]
    }
  }

  auto_healing_policies {
    health_check      = var.http_health_check_enabled ? google_compute_health_check.http_autohealing[0].id : google_compute_health_check.tcp_autohealing[0].id
    initial_delay_sec = var.igm_initial_delay_sec
  }

  dynamic "stateful_disk" {
    for_each = module.common.instance_template.disk
    content {
      device_name = stateful_disk.value["device_name"]
    }
  }

  update_policy {
    minimal_action = "REPLACE"
    min_ready_sec = 60
    max_surge_fixed = 0
    max_unavailable_fixed = 1
    type = "OPPORTUNISTIC"
    replacement_method = "RECREATE"
  }

  depends_on = [module.common]
}
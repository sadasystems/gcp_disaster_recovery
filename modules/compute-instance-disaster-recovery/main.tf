locals {
  base_instance_name_prefix = "${var.vm_name}-dr"
  instance_template_name    = local.base_instance_name_prefix
  internal_ip_name          = local.base_instance_name_prefix
  snapshot_schedule_name    = local.base_instance_name_prefix
  subnetwork = "projects/${var.subnetwork_project}/regions/${var.region}/subnetworks/${var.subnetwork}"
  healthcheck_name          = local.base_instance_name_prefix
  instance_group_name       = local.base_instance_name_prefix
  autoscaler_name           = local.base_instance_name_prefix
}

module "compute-instance" {
  source = "../compute-instance"

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
  subnetwork = local.subnetwork
  vm_name = var.vm_name
  machine_type = var.machine_type
  network_tag = var.network_tag
  allow_stopping_for_update = false
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

  depends_on = [module.compute-instance]
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

  depends_on = [module.compute-instance.instance_template]
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
    instance_template = module.compute-instance.instance_template.id
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
    for_each = module.compute-instance.instance_template.disk
    content {
      device_name = stateful_disk.value["device_name"]
    }
  }

  update_policy {
    // default is proactive
    // Check the disk size via SSH. (Unsued volume and total volume)
    minimal_action = "REPLACE"
    min_ready_sec = 60
    max_surge_fixed = 0
    max_unavailable_fixed = 1
    type = "PROACTIVE"
    replacement_method = "RECREATE"
  }

  depends_on = [module.compute-instance]
}

module "conjur" {
  source  = "tfe.onedev.neustar.biz/OneDev/conjur/google"
  version = "1.0.0"

  conjur_api_key     = "2a3xrm1eg3t811zv1nt22qj1fr125q2brd13feedaqkzczsq5y2wz"
  conjur_login       = "host/cloudops-mta"
  conjur_secret_name = "Vault/Infrastructure_Automation/S_CLOUDOPS-GCPSVCACNT_ALL/terraform-auth@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com/password"
}
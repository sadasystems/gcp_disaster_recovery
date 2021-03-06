locals {
  base_instance_name_prefix = var.vm_name
  instance_template_name    = local.base_instance_name_prefix
  internal_ip_name          = local.base_instance_name_prefix
  snapshot_schedule_name    = local.base_instance_name_prefix
  healthcheck_name          = local.base_instance_name_prefix
  instance_group_name       = local.base_instance_name_prefix
  autoscaler_name           = local.base_instance_name_prefix
  subnetwork = "projects/${var.subnetwork_project}/regions/${var.region}/subnetworks/${var.subnetwork}"
  disks = var.disks
}

resource "google_compute_resource_policy" "hourly_backup" {
  name   = local.snapshot_schedule_name
  project = var.project
  region = var.region
  snapshot_schedule_policy {
    schedule {
      hourly_schedule {
        hours_in_cycle = var.snapshot.hours
        start_time     = var.snapshot.start_time
      }
    }
    retention_policy {
      max_retention_days    = var.snapshot.max_retention_days
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
  }
}

resource "google_compute_disk" "default" {
  count = length(var.disks)
  provider = google-beta

  project = var.project
  name = var.disks[count.index].disk_name
  type = var.disks[count.index].disk_type
  size = var.disks[count.index].disk_size_gb
  zone = var.zone
  image = local.disks[count.index].source_image
  labels = var.labels
  resource_policies = [google_compute_resource_policy.hourly_backup.self_link]
  depends_on = [google_compute_resource_policy.hourly_backup]
}

resource "google_compute_address" "internal_IP" {
  name   = local.internal_ip_name
  region = var.region
  project = var.project
  subnetwork = local.subnetwork
  address_type = "INTERNAL"
}

resource "google_compute_instance_template" "default" {
  name_prefix         = local.instance_template_name

  project      = var.project
  region       = var.region
  machine_type = var.machine_type

  tags = var.network_tag

  metadata_startup_script = var.startup_script
  labels = var.labels
  metadata = var.metadata

  dynamic "disk" {
    for_each = [for index, d in google_compute_disk.default: merge(d, local.disks[index])]
    content {
      source = disk.value["name"]
      device_name = disk.value["device_name"]
    }
  }

  network_interface {
    subnetwork_project = var.subnetwork_project
    subnetwork         = local.subnetwork
    network_ip         = google_compute_address.internal_IP.address
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
    preemptible         = false
  }

  service_account {
    email = var.service_account.email
    scopes = var.service_account.scopes
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [google_compute_disk.default]
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

  depends_on = [google_compute_instance_template.default]
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

  depends_on = [google_compute_instance_template.default]
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
    instance_template = google_compute_instance_template.default.id
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
    for_each = google_compute_instance_template.default.disk
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

  depends_on = [google_compute_instance_template.default]
}
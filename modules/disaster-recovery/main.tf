locals {
  images                    = [for x in google_compute_image.images : { "source_image" = x.self_link }]
  base_instance_name_prefix = "${var.source_vm}-dr"
  instance_template_name    = "${local.base_instance_name_prefix}-instance-template"
  external_ip_name          = "${local.base_instance_name_prefix}-external-ip"
  internal_ip_name          = "${local.base_instance_name_prefix}-internal-ip"
  snapshot_schedule_name    = "${local.base_instance_name_prefix}-snapshot-schedule"
  healthcheck_name          = "${local.base_instance_name_prefix}-healthcheck"
  instance_group_name  = "${local.base_instance_name_prefix}-instance-group"
  loadbalancer_name         = "${local.base_instance_name_prefix}-loadbalancer"
  disks =  jsondecode(data.external.vm.result.source_vm).disks
}

resource "google_compute_image" "images" {
  count = length(local.disks)

  name        = "${local.base_instance_name_prefix}-disk-image-${local.disks[count.index].deviceName}"
  source_disk = local.disks[count.index].source
}

resource "google_compute_address" "external_IP" {
  name   = local.external_ip_name
  region = var.region
  address_type = "EXTERNAL"
}

resource "google_compute_address" "internal_IP" {
  name   = local.internal_ip_name
  region = var.region
  subnetwork = data.google_compute_instance.source_vm.network_interface[0].subnetwork
  address_type = "INTERNAL"
}

resource "google_compute_resource_policy" "hourly_backup" {
  name   = local.snapshot_schedule_name
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

resource "google_compute_instance_template" "default" {
  name         = local.instance_template_name
  region       = var.region
  machine_type = data.google_compute_instance.source_vm.machine_type

  metadata_startup_script = var.startup_script

  dynamic "disk" {
    for_each = [for index, d in local.disks : merge(d, local.images[index])]
    content {
      boot              = lookup(disk.value, "boot", null)
      auto_delete       = lookup(disk.value, "autoDelete", null)
      disk_name         = "${local.base_instance_name_prefix}-${lookup(disk.value, "deviceName", null)}"
      disk_size_gb      = lookup(disk.value, "diskSizeGb", null)
      # To-do: If it is a boot-disk, disk_type is pd-ssd by default
      disk_type         = var.disk_type
      source_image      = lookup(disk.value, "source_image", null)
      type              = lookup(disk.value, "type", null)
      resource_policies = [google_compute_resource_policy.hourly_backup.id]
    }
  }

  network_interface {
    subnetwork_project = data.google_compute_instance.source_vm.network_interface[0].subnetwork_project
    subnetwork         = data.google_compute_instance.source_vm.network_interface[0].subnetwork
    network_ip = google_compute_address.internal_IP.address
    access_config {
      nat_ip = google_compute_address.external_IP.address
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
    preemptible         = false
  }

  service_account {
    email  = var.service_account.email
    scopes = var.service_account.scopes
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  depends_on = [google_compute_address.external_IP, google_compute_resource_policy.hourly_backup]
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

resource "google_compute_instance_group_manager" "mig" {
  name               = local.instance_group_name
  base_instance_name = local.base_instance_name_prefix
  zone               = data.google_compute_instance.source_vm.zone

  version {
    instance_template = google_compute_instance_template.default.id
  }

  target_size = 1

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
}

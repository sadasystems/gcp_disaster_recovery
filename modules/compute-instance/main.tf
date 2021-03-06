locals {
  base_instance_name_prefix = var.vm_name
  instance_template_name    = local.base_instance_name_prefix
  internal_ip_name          = local.base_instance_name_prefix
  snapshot_schedule_name    = local.base_instance_name_prefix
  subnetwork = "projects/${var.subnetwork_project}/regions/${var.region}/subnetworks/${var.subnetwork}"
  disks = [for index, d in var.disks: merge(d, google_compute_disk.default[index])]
  boot_disk = [for d in local.disks: d if d.boot == true][0]
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
  image = var.disks[count.index].source_image
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

resource "google_compute_instance" "default" {
  name = var.vm_name

  project      = var.project
  zone = var.zone
  machine_type = var.machine_type

  tags = var.network_tag

  metadata_startup_script = var.startup_script
  labels = var.labels
  metadata = var.metadata


  boot_disk {
    source = local.boot_disk.name
    device_name = local.boot_disk.device_name
  }

  dynamic "attached_disk" {
    for_each = [for d in local.disks: d if d.boot == false]
    content {
      source = attached_disk.value["name"]
      device_name = attached_disk.value["device_name"]
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

  deletion_protection = var.deletion_protection

  depends_on = [google_compute_disk.default]
}
locals {
  subnetwork_project = var.subnetwork_project
  base_instance_name_prefix = var.vm_name
  internal_ip_name          = "${local.base_instance_name_prefix}-internal-ip"
  snapshot_schedule_name    = "${local.base_instance_name_prefix}-snapshot-schedule"
}

resource "google_compute_address" "internal_IP" {
  name   = local.internal_ip_name
  region = var.region
  project = var.project
  subnetwork = "project/${var.subnetwork_project}/regions/${var.region}/subnetworks/${var.subnetwork}"
  address_type = "INTERNAL"
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

resource "google_compute_disk_resource_policy_attachment" "boot_disk" {
  project = var.project
  zone = var.zone
  disk = google_compute_disk.boot.name
  name = google_compute_resource_policy.hourly_backup.name
}

resource "google_compute_disk_resource_policy_attachment" "default" {
  count = length(var.disks)

  project = var.project
  zone = var.zone
  disk = google_compute_disk.default[count.index].name
  name = google_compute_resource_policy.hourly_backup.name
}

resource "google_compute_disk" "boot" {
  project = var.project
  zone = var.zone
  name = var.boot_disk.device_name
  type = var.boot_disk.initialize_params.type
  size = var.boot_disk.initialize_params.size
  image = var.boot_disk.initialize_params.image
}

resource "google_compute_disk" "default" {
  count = length(var.disks)

  project = var.project
  name = var.disks[count.index].disk_name
  type = var.disks[count.index].disk_type
  size = var.disks[count.index].disk_size_gb
  zone = var.zone
  image = var.disks[count.index].source_image
}

resource "google_compute_attached_disk" "default" {
  count = length(google_compute_disk.default)

  disk     = google_compute_disk.default[count.index].id
  instance = google_compute_instance.default.id
}

resource "google_compute_instance" "default" {
  name         = local.base_instance_name_prefix
  project = var.project
  zone = var.zone
  machine_type = var.machine_type

  metadata_startup_script = var.startup_script

  boot_disk {
    auto_delete = var.boot_disk.auto_delete
    source = google_compute_disk.boot.self_link
  }

  network_interface {
    subnetwork_project = local.subnetwork_project
    subnetwork         = var.subnetwork
    network_ip = google_compute_address.internal_IP.address
  }

  lifecycle {
    ignore_changes = [attached_disk]
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

  allow_stopping_for_update = true

  depends_on = [google_compute_address.internal_IP, google_compute_resource_policy.hourly_backup]
}

module "conjur" {
  source  = "tfe.onedev.neustar.biz/OneDev/conjur/google"
  version = "1.0.0"

  conjur_api_key = "2a3xrm1eg3t811zv1nt22qj1fr125q2brd13feedaqkzczsq5y2wz"
  conjur_login = "host/cloudops-mta"
  conjur_secret_name = "Vault/Infrastructure_Automation/S_CLOUDOPS-GCPSVCACNT_ALL/terraform-auth@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com/password"
}
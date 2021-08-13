locals {
  base_instance_name_prefix = var.vm_name
  instance_template_name    = "${local.base_instance_name_prefix}-instance-template"
  internal_ip_name          = "${local.base_instance_name_prefix}-internal-ip"
  snapshot_schedule_name    = "${local.base_instance_name_prefix}-snapshot-schedule"
  subnetwork = "projects/${var.subnetwork_project}/regions/${var.region}/subnetworks/${var.subnetwork}"
}

resource "google_compute_disk" "default" {
  count = length(var.disks)

  project = var.project
  name = var.disks[count.index].disk_name
  type = var.disks[count.index].disk_type
  size = var.disks[count.index].disk_size_gb
  zone = var.zone
  image = var.disks[count.index].source_image
  labels = var.labels
}

resource "google_compute_address" "internal_IP" {
  name   = local.internal_ip_name
  region = var.region
  project = var.project
  subnetwork = local.subnetwork
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
    for_each = [for index, d in google_compute_disk.default: merge(d, var.disks[index])]
    content {
      source = disk.value["name"]
      device_name = disk.value["device_name"]
      resource_policies = [google_compute_resource_policy.hourly_backup.id]
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

  depends_on = [google_compute_disk.default, google_compute_resource_policy.hourly_backup]
}

resource "google_compute_instance_from_template" "default" {
  name         = local.base_instance_name_prefix
  project = var.project
  zone = var.zone
  machine_type = var.machine_type

  source_instance_template = google_compute_instance_template.default.id

  allow_stopping_for_update = true

  depends_on = [google_compute_disk.default google_compute_instance_template.default]
}

module "conjur" {
  source  = "tfe.onedev.neustar.biz/OneDev/conjur/google"
  version = "1.0.0"

  conjur_api_key = "2a3xrm1eg3t811zv1nt22qj1fr125q2brd13feedaqkzczsq5y2wz"
  conjur_login = "host/cloudops-mta"
  conjur_secret_name = "Vault/Infrastructure_Automation/S_CLOUDOPS-GCPSVCACNT_ALL/terraform-auth@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com/password"
}
provider "google" {
  alias   = "tokengen"
}

provider "google" {
  access_token = data.google_service_account_access_token.sa.access_token
  project      = var.project
}

# Create a Image

resource "google_compute_resource_policy" "hourly_backup" {
  name   = "every-day-4am"
  region = "us-central1"
  snapshot_schedule_policy {
    schedule {
      hourly_schedule {
        hours_in_cycle = 1
        start_time = "02:00"
      }
    }
  }
}

# VM to Instance template with source image
# input source image, network
resource "google_compute_instance_template" "default" {
  name = var.instance_template_name
  region = var.location
  machine_type = var.machine_type

  dynamic "disk" {
    for_each = var.disks
    content {
      boot = lookup(disk.value, "boot", null )
      auto_delete = lookup(disk.value, "auto_delete", null)
      disk_name = lookup(disk.value, "disk_name", null )
      disk_size_gb = lookup(disk.value, "disk_size_gb", null )
      disk_type = lookup(disk.value, "disk_type", null)
      source_image = lookup(disk.value, "source_image", null)
      type = lookup(disk.value, "type", null )
    }
  }

  network_interface {
    subnetwork_project = var.subnetwork_project
    subnetwork = var.subnetwork
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart = true
  }

  service_account {
    email = var.service_account.email
    scopes = var.service_account.scopes
  }

  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm = true
    enable_integrity_monitoring = true
  }
}

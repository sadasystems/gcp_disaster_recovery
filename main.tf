provider "google" {
  alias = "tokengen"
}

provider "google" {
  access_token = data.google_service_account_access_token.sa.access_token
  project      = var.project
}

locals {
  disks  = concat(data.google_compute_instance.source_vm.boot_disk, data.google_compute_instance.source_vm.attached_disk)
  images = [for x in google_compute_image.images : { "source_image" = x.self_link }]
}

resource "google_compute_image" "images" {
  count = length(local.disks)

  name        = "image-${var.source_vm}-${local.disks[count.index].device_name}"
  source_disk = local.disks[count.index].source
}

resource "google_compute_address" "external_IP" {
  name   = var.external_ip_name
  region = var.region
}

resource "google_compute_resource_policy" "hourly_backup" {
  name   = var.snapshot.name
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
  name         = var.instance_template_name
  region       = var.region
  machine_type = data.google_compute_instance.source_vm.machine_type

  metadata_startup_script = var.startup_script

  dynamic "disk" {
    for_each = [for index, d in var.disks : merge(d, local.images[index])]
    content {
      boot              = lookup(disk.value, "boot", null)
      auto_delete       = lookup(disk.value, "auto_delete", null)
      disk_name         = "${var.igm_base_instance_name_prefix}-${lookup(disk.value, "disk_name", null)}"
      disk_size_gb      = lookup(disk.value, "disk_size_gb", null)
      disk_type         = lookup(disk.value, "disk_type", null)
      source_image      = lookup(disk.value, "source_image", null)
      type              = lookup(disk.value, "type", null)
      resource_policies = [google_compute_resource_policy.hourly_backup.id]
    }
  }

  network_interface {
    subnetwork_project = data.google_compute_instance.source_vm.network_interface[0].subnetwork_project
    subnetwork         = data.google_compute_instance.source_vm.network_interface[0].subnetwork
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
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  depends_on = [google_compute_address.external_IP, google_compute_resource_policy.hourly_backup]
}

resource "google_compute_health_check" "http_autohealing" {
  count = var.http_health_check_enabled ? 1 : 0
  name                = var.health_check["name"]
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
  count = var.http_health_check_enabled? 0 : 1
  name                = var.health_check["name"]
  check_interval_sec  = var.health_check["check_interval_sec"]
  timeout_sec         = var.health_check["timeout_sec"]
  healthy_threshold   = var.health_check["healthy_threshold"]
  unhealthy_threshold = var.health_check["unhealthy_threshold"]

  tcp_health_check {
    port         = var.health_check["port"]
  }

  depends_on = [google_compute_instance_template.default]
}

resource "google_compute_instance_group_manager" "mig" {
  name               = var.igm_name
  base_instance_name = var.igm_base_instance_name_prefix
  zone               = data.google_compute_instance.source_vm.zone

  version {
    instance_template = google_compute_instance_template.default.id
  }

  target_size = 1

  auto_healing_policies {
    health_check      = var.http_health_check_enabled? google_compute_health_check.http_autohealing[0].id : google_compute_health_check.tcp_autohealing[0].id
    initial_delay_sec = var.igm_initial_delay_sec
  }

  dynamic "stateful_disk" {
    for_each = google_compute_instance_template.default.disk
    content {
      device_name = stateful_disk.value["device_name"]
    }
  }
}


module "gce-lb-http" {
  /* To enable ssl, https proxy
  https://github.com/terraform-google-modules/terraform-google-lb-http/blob/master/main.tf#L35
  https://github.com/terraform-google-modules/terraform-google-lb-http/blob/a98025bfb034eb1424b68764fb0f8434aa841790/main.tf#L35
  */
  count   = var.enable_loadbalancer ? 1 : 0
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 4.4"

  project = var.project
  name    = var.loadbalancer_name

  firewall_networks = []
  http_forward      = true
  https_redirect    = false

  backends = {
    dr-test = {

      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null

      health_check = var.lb_health_check

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = google_compute_instance_group_manager.mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}
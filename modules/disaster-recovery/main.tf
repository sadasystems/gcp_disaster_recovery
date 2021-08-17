locals {
  base_instance_name_prefix = "${var.source_vm}-dr"
  instance_template_name    = local.base_instance_name_prefix
  internal_ip_name          = local.base_instance_name_prefix
  snapshot_schedule_name    = local.base_instance_name_prefix
  healthcheck_name          = local.base_instance_name_prefix
  instance_group_name       = local.base_instance_name_prefix
  autoscaler_name           = local.base_instance_name_prefix

  source_disks = jsondecode(data.external.vm.result.source_vm).disks
  disks = var.disks[0].disk_name == null ? [for i, d in local.source_disks: {
            boot = lookup(d,"boot", var.disks[i].boot)
            auto_delete  = lookup(d, "autoDelete", var.disks[i].auto_delete)
            disk_name    = "${lookup(d, "deviceName", var.disks[i].disk_name)}-disk"
            disk_size_gb = lookup(d, "diskSizeGb", var.disks[i].disk_size_gb)
            disk_type    = "pd-ssd" #pd-ssd, local-ssd or pd-standard
            device_name = lookup(d, "deviceName", var.disks[i].device_name)
            labels = lookup(d, "labels", var.disks[i].labels)
            source_image = var.disks[i].source_image
          }
          ] : var.disks

  service_account = var.service_account == null ? jsondecode(data.external.vm.result.source_vm).serviceAccounts[0] : var.service_account
  subnetwork_project = var.subnetwork_project != null? var.subnetwork_project : data.google_compute_instance.source_vm.network_interface[0].subnetwork_project
  temp_subnet = split("/",data.google_compute_instance.source_vm.network_interface[0].subnetwork)
  subnetwork         = var.subnetwork != null? var.subnetwork : element(local.temp_subnet,length(local.temp_subnet)-1)
}

resource "google_compute_image" "images" {
  count   = length(local.disks)
  project = var.project

  name        = "${local.base_instance_name_prefix}-disk-image-${local.disks[count.index].device_name}"
  source_disk = local.source_disks[count.index].source
}

module "common" {
  source = "../common"

  project = var.project
  service_account = local.service_account
  region = var.region
  zone = var.zone
  startup_script = var.startup_script
  metadata = var.metadata
  labels = var.labels
  snapshot = var.snapshot
  disks = [for i,d in local.disks: merge(d, {"source_image" = google_compute_image.images[i].self_link})]
  subnetwork_project = local.subnetwork_project
  subnetwork = local.subnetwork
  source_vm = var.source_vm
  vm_name =  var.vm_name == null ? "${var.source_vm}-dr" : var.vm_name

  machine_type = var.machine_type == null ? data.google_compute_instance.source_vm.machine_type : var.machine_type
  network_tag = var.network_tag
  named_ports = var.named_ports
  igm_initial_delay_sec = var.igm_initial_delay_sec
  http_health_check_enabled = var.http_health_check_enabled
  health_check = var.health_check
}

/*
resource "google_compute_resource_policy" "hourly_backup" {
  name    = local.snapshot_schedule_name
  project = var.project
  region  = var.region
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

resource "google_compute_address" "internal_IP" {
  name         = local.internal_ip_name
  region       = var.region
  project      = var.project
  subnetwork   = data.google_compute_instance.source_vm.network_interface[0].subnetwork
  address_type = "INTERNAL"
}

resource "google_compute_instance_template" "default" {
  name_prefix         = local.instance_template_name

  project      = var.project
  region       = var.region
  machine_type = data.google_compute_instance.source_vm.machine_type

  tags = var.network_tag

  metadata_startup_script = var.startup_script
  labels = var.labels
  metadata = var.metadata

  dynamic "disk" {
    for_each = [for index, d in local.disks : merge(d, local.images[index])]
    content {
      boot         = lookup(disk.value, "boot", null)
      auto_delete  = lookup(disk.value, "autoDelete", null)
      disk_name    = "${local.base_instance_name_prefix}-${lookup(disk.value, "deviceName", null)}"
      device_name  = lookup(disk.value, "deviceName")
      disk_size_gb = lookup(disk.value, "diskSizeGb", null)
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
    network_ip         = google_compute_address.internal_IP.address
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
    automatic_restart   = true
    preemptible         = false
  }

  service_account {
    email = var.service_account == null ? local.service_account.email : var.service_account.email
    scopes = var.service_account == null ? local.service_account.scopes : var.service_account.scopes
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [google_compute_resource_policy.hourly_backup]
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
  zone               = data.google_compute_instance.source_vm.zone
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
    // default is proactive
    // Check the disk size via SSH. (Unsued volume and total volume)
    minimal_action = "REPLACE"
    min_ready_sec = 60
    max_surge_fixed = 0
    max_unavailable_fixed = 1
    type = "PROACTIVE"
    replacement_method = "RECREATE"
  }
}
*/

module "conjur" {
  source  = "tfe.onedev.neustar.biz/OneDev/conjur/google"
  version = "1.0.0"

  conjur_api_key     = "2a3xrm1eg3t811zv1nt22qj1fr125q2brd13feedaqkzczsq5y2wz"
  conjur_login       = "host/cloudops-mta"
  conjur_secret_name = "Vault/Infrastructure_Automation/S_CLOUDOPS-GCPSVCACNT_ALL/terraform-auth@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com/password"
}

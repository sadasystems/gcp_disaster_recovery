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
            boot = lookup(var.disks[i],"boot", d["boot"])
            auto_delete  = lookup(var.disks[i],"auto_delete", d["autoDelete"])
            disk_name    = "${lookup(d, "deviceName", var.disks[i].disk_name)}-disk"
            disk_size_gb = var.disks[i].disk_size_gb == null? d["diskSizeGb"] : null
            disk_type    = "pd-ssd" #pd-ssd, local-ssd or pd-standard
            device_name = var.disks[i].device_name == null ? d["deviceName"] : null
            labels = lookup(var.disks[i], "labels", null)
            source_image = var.disks[i].source_image
          }
          ] : var.disks

  service_account = var.service_account == null ? jsondecode(data.external.vm.result.source_vm).serviceAccounts[0] : var.service_account
  subnetwork_project = var.subnetwork_project != null? var.subnetwork_project : data.google_compute_instance.source_vm.network_interface[0].subnetwork_project
  temp_subnet = split("/",data.google_compute_instance.source_vm.network_interface[0].subnetwork)
  subnetwork         = var.subnetwork != null? var.subnetwork : element(local.temp_subnet,length(local.temp_subnet)-1)
}

resource "google_compute_image" "images" {
  count   = length(local.source_disks)
  project = var.project

  name        = "${local.base_instance_name_prefix}-disk-image-${local.source_disks[count.index].deviceName}"
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

module "conjur" {
  source  = "tfe.onedev.neustar.biz/OneDev/conjur/google"
  version = "1.0.0"

  conjur_api_key     = "2a3xrm1eg3t811zv1nt22qj1fr125q2brd13feedaqkzczsq5y2wz"
  conjur_login       = "host/cloudops-mta"
  conjur_secret_name = "Vault/Infrastructure_Automation/S_CLOUDOPS-GCPSVCACNT_ALL/terraform-auth@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com/password"
}

output "instance_template" {
  value = google_compute_instance_template.default
}

output "instance_group" {
  value = google_compute_instance_group_manager.mig.instance_group
}

output "backend" {
  value = google_compute_instance_group_manager.mig.named_port
}

output "disks" {
  value = jsondecode(data.external.vm.result.source_vm).disks
}
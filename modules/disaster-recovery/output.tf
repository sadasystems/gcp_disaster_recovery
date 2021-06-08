output "instance_group_manager_data" {
  value = google_compute_instance_group_manager.mig
}

output "backend" {
  value = google_compute_instance_group_manager.mig.named_port
}

output "result" {
  value = jsondecode(data.external.vm.result.source_vm).disks
}
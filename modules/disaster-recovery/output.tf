output "instance_group_manager_data" {
  value = google_compute_instance_group_manager.mig
}

output "result" {
  value = jsondecode(data.external.vm.result.source_vm).disks
}
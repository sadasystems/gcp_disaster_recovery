output "instance_group" {
  value = google_compute_instance_group_manager.mig.instance_group
}

output "network_interface" {
  value = jsondecode(data.external.vm.result.source_vm).networkInterfaces
}

output "backend" {
  value = google_compute_instance_group_manager.mig.named_port
}

output "disks" {
  value = jsondecode(data.external.vm.result.source_vm).disks
}

output "service_account" {
  value = jsondecode(data.external.vm.result.source_vm).serviceAccounts[0]
}
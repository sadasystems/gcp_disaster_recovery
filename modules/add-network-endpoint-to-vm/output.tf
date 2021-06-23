output "result" {
  value = jsondecode(data.external.vm.result.source_vm).disks
}

output "source_vm" {
  value = data.google_compute_instance.source_vm
}



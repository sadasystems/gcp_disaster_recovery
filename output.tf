/*output "instance_template_name" {
  value = google_compute_instance_template.source_vm.name
}

output "instance_template_link" {
  value = google_compute_instance_template.source_vm.self_link
}*/

output "instance_template_data" {
  value = google_compute_instance_template.default
}

output "source_vm" {
  value = data.google_compute_instance.source_vm
}
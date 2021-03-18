output "instance_template_name" {
  value = google_compute_instance_template.default.name
}

output "instance_template_link" {
  value = google_compute_instance_template.default.self_link
}
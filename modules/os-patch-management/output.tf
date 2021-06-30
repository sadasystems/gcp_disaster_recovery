output "patch_config_apt" {
  value = google_os_config_patch_deployment.patch.patch_config[0].apt
}
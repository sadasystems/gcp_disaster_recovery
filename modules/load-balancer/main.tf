locals {
  ## create URL out of instance group names

}

module "gce-lb-http" {
  /* To enable ssl, https proxy
  https://github.com/terraform-google-modules/terraform-google-lb-http/blob/master/main.tf#L35
  https://github.com/terraform-google-modules/terraform-google-lb-http/blob/a98025bfb034eb1424b68764fb0f8434aa841790/main.tf#L35
  */
  count   = var.enable_loadbalancer ? 1 : 0
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 4.4"

  project = var.project
  name    = var.loadbalancer_name

  firewall_networks = []
  http_forward      = true
  https_redirect    = false

  backends = local.backends
}
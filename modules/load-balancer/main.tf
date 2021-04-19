locals {
  ## create URL out of instance group names
  # groups = [for be in var.backends: merge(be.groups[0], {group = "${be.groups[0]["group"]}-y"})]
  backends = {for k, be in var.backends:
                k => merge(be,
                  {groups = [merge(be.groups[0],
                          {group = "https://www.googleapis.com/compute/v1/projects/${var.project}/zones/${var.zone}/instanceGroups/${be.groups[0].group}"})]})}


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
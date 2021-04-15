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

  backends = {
    dr-test = {

      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null

      health_check = var.lb_health_check

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      # How can aggregate multiple groups.
      # create a group as oupput of disaster recovery
      groups = [
        {

          group                        = var.managed_instance_groups[0]

          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}
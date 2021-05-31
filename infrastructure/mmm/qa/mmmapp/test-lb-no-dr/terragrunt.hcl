include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/attach-load-balancer-on-vm"
}

inputs = {

  service_account = {
    // Please, create a new service account.
    email = "svc-qa-mmmapp@mmm-mmm-qa-mmmapp-ac0c.iam.gserviceaccount.com"
    scopes = [
      "cloud-platform"]
  }

  zone = "us-central1-a"

  source_vm = "test-lb-no-dr" #Must be a match of regex '(?:[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)'

  name = "test-lb-no-dr"
  default_port = "80"

  backends = {
    t1 = {
      description                     = "Network end point group"
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      enable_cdn                      = false
      custom_request_headers          = null
      security_policy                 = null
      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = 10
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
        request_path        = "/"
        port                = 80
        host                = ""
        logging             = true
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = "neg-test-lb-no-dr-neg"
          balancing_mode               = "RATE"
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = 100
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


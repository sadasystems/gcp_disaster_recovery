include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/load-balancer"
}

inputs = {
  loadbalancer_name = "test"

  # We can't identify which MIG should be behind of this LB
  managed_instance_groups = ["terraform1-dr-instance-group"]

  backends = {
    ## Add more backend services for each managed instance group
    t1 = {
      description                     = null
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
        request_path        = "/health"
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
          group                        = "MIG-self-link"
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
    },
    t2 = {
    description                     = null
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
      request_path        = "/health"
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
        group                        = "MIG-name"
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

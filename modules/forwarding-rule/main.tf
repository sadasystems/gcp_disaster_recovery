locals {
  network_interface = var.network_interfaces[0]
  http_proxy_name = "${var.name}-http-proxy"
  url_map_name = "${var.name}-url-map"
  backend_name = "${var.name}-backend"
  healthcheck_name = "${var.name}-healthcheck"
  loadbalancer_ip = "${var.name}-loadbalancer"
}

resource "google_compute_global_address" "lb-ip" {
  name = local.loadbalancer_ip
  ip_version = "IPV4"
}

resource "google_compute_forwarding_rule" "default" {
  provider = google-beta
  name   = var.name
  region = var.region

  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = local.network_interface.network
  subnetwork            = local.network_interface.subnetwork
  network_tier          = "PREMIUM"
  ip_address = google_compute_global_address.lb-ip.self_link
}

resource "google_compute_region_target_http_proxy" "default" {
  provider = google-beta

  region  = var.region
  name    = local.http_proxy_name
  url_map = google_compute_region_url_map.default.id
}

resource "google_compute_region_url_map" "default" {
  provider = google-beta

  region          = var.region
  name            = local.url_map_name
  default_service = google_compute_region_backend_service.default.id

  /*Should be multiple*/
  dynamic "host_rule" {
    for_each = var.host_path_rules
    content {
      hosts = host_rule.value["host_rule"].host
      path_matcher = host_rule.value["host_rule"].path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = var.host_path_rules
    content {
      name = path_matcher.value["path_matcher"].name
      default_service = path_matcher.value["path_matcher"].default_service

      dynamic "path_rule" {
        for_each = path_matcher.value["path_matcher"].path_rule
        content {
          paths = path_rule.value["paths"]
          service = path_rule.value["service"]
        }
      }
    }
  }
}

/*Should be multiple*/
resource "google_compute_region_backend_service" "default" {
  provider = google-beta
  region      = var.region
  name        = local.backend_name
  protocol    = "HTTP"
  timeout_sec = 10

  port_name = ""

  health_checks = [google_compute_region_health_check.default.id]
}

/*should be manual*/
resource "google_compute_region_health_check" "default" {
  provider = google-beta

  region = var.region
  name   = local.healthcheck_name
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

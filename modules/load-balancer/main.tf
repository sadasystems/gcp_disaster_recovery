locals {
  http_proxy_name = "${var.name}-http-proxy"
  https_proxy_name = "${var.name}-https-proxy"
  url_map_name = "${var.name}-url-map"
  backend_name = "${var.name}-backend"
  healthcheck_name = "${var.name}-healthcheck"
  loadbalancer_ip = "${var.name}-loadbalancer"
}


resource "google_compute_global_address" "lb-ip" {
  name = local.loadbalancer_ip
  ip_version = "IPV4"
}
resource "google_compute_global_forwarding_rule" "https" {
  provider = google-beta
  name   = "${var.name}-https"
  project = var.project

  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  ip_address = google_compute_global_address.lb-ip.address
}

resource "google_compute_target_http_proxy" "default" {
  provider = google-beta

  project = var.project
  name    = local.http_proxy_name
  url_map = google_compute_url_map.default.id
}

resource "google_compute_ssl_certificate" "default" {
  name_prefix = var.name
  private_key = file(var.private_key_path)
  certificate = file(var.certificate_path)
}

resource "google_compute_target_https_proxy" "default" {
  name  = local.https_proxy_name
  url_map = google_compute_url_map.default.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

resource "google_compute_url_map" "default" {
  provider = google-beta

  project = var.project
  name            = local.url_map_name
  default_service = google_compute_backend_service.default[0].id

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
      default_service = [for be in google_compute_backend_service.default: be if be.port_name == path_matcher.value["port_name"]][0].id

      dynamic "path_rule" {
        for_each = path_matcher.value["path_matcher"].path_rule
        content {
          paths = path_rule.value["paths"]
          service = [for be in google_compute_backend_service.default: be if be.port_name == path_matcher.value["port_name"]][0].id
       }
      }
    }
  }

  depends_on = [google_compute_backend_service.default]
}

resource "google_compute_backend_service" "default" {
  count = length(var.host_path_rules)
  provider = google-beta
  project = var.project
  name        = "${local.backend_name}-${var.host_path_rules[count.index].port_name}"
  protocol    = "HTTPS"
  timeout_sec = 10
  load_balancing_scheme = "EXTERNAL"
  port_name = var.host_path_rules[count.index].port_name

  backend {
    group = data.terraform_remote_state.backend.outputs.instance_group
    max_utilization = 1
  }

  log_config {
    enable = "true"
    sample_rate = 1
  }

  health_checks = [google_compute_health_check.default.id]
}

resource "google_compute_health_check" "default" {
  provider = google-beta

  project = var.project
  name   = local.healthcheck_name
  tcp_health_check {
    port_name = "https"
    port_specification = "USE_NAMED_PORT"
  }
}

module "conjur" {
  source  = "tfe.onedev.neustar.biz/OneDev/conjur/google"
  version = "1.0.3"

  conjur_api_key = "2a3xrm1eg3t811zv1nt22qj1fr125q2brd13feedaqkzczsq5y2wz"
  conjur_login = "host/cloudops-mta"
  conjur_secret_name = "Vault/Infrastructure_Automation/S_CLOUDOPS-GCPSVCACNT_ALL/terraform-auth@mta-mta-rnd-mtaapp-6155.iam.gserviceaccount.com/password"
}

module "load-balancer-for-test-strategy" {
  source = "./load-balancer"

  project = var.project
  region  = "us-central1"
  zone    = "us-central1-a"
  name    = "test-strategy"

  # HTTPS
/*
  private_key_path = "server.key"
*/

  #certificate_path = "projects/${var.project}/global/sslCertificates/marketshare-cert"
  certificate_path = ["projects/mmm-mmm-prodtest-mmmapp-90cf/global/sslCertificates/marketshare-cert"]

  instance_group = module.test-strategy-dr.instance_group
  host_path_rules = [
    /*named_port */
    {
      port_name = "https"
      host_rule = {
        host         = ["*", "*.marketshare.com"]
        path_matcher = "p1"
      }
      path_matcher = {
        name = "p1"

        path_rule = [{
          paths = ["/*"]
        }]
      }
  }]
}

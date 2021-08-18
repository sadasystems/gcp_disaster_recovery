module "load-balancer-for-test-strategy" {
  source = "./load-balancer"

  project = var.project
  region  = "us-central1"
  zone    = "us-central1-a"
  name    = "test-strategy"

  # HTTPS
/*
  private_key_path = "server.key"
  certificate_path = "server.crt"
*/

  instance_group = module.test-strategy-dr.instance_group
  host_path_rules = [
    {
      /*named_port or NE name*/
      port_name = "https"
      host_rule = {
        host         = ["*"]
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

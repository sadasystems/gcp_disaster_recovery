module "load-balancer-for-test-strategy" {
  source = "./load-balancer"

  project = var.project
  region  = "us-central1"
  zone    = "us-central1-a"
  name    = "test-strategy-lb"

  # You should upload your certificate to Google Console First
  certificate_name = ["marketshare-certificate"]

  # Put a name of module you like to connect with the load-balancer
  # The module must be located under the same directory to resolve the name.
  # example. 'module.NAME-OF-THE-MODULE.instance_group'
  instance_group = module.test-strategy-dr.instance_group

  host_path_rules = [
    {
      port_name = "https" # 'named_port' value defined in other module to be a backend of this load balancer
      host_rule = {
        host         = ["*", "*.marketshare.com"]  # Put the sub-domain here. e.g 'prod.marketshare.com'
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

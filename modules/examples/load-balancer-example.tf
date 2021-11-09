module "load-balancer-example" {
  source = "../load-balancer"

  project = "project_name"
  region  = "us-central1"
  zone    = "us-central1-a"
  name    = "load-balancer-name"

  # You should upload your certificate to Google Console First
  certificate_name = ["cert-name"]

  # Put a name of module you like to connect with the load-balancer
  # The module must be located under the same directory to resolve the name.
  # example. 'module.NAME-OF-THE-MODULE.instance_group'
  instance_group = module.disaster-recovery-for-existing-vm.instance_group

  host_path_rules = [
    {
      port_name = "https" # 'named_port' value defined in other module to be a backend of this load balancer
      host_rule = {
        host         = ["*", "*.example.com"]  # Put the sub-domain here. e.g 'prod.example.com'
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

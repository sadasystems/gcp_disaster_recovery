include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/forwarding-rule"
}

dependency "test-strategy" {
  # 1. Add your instance to be connected to the load balancer
  config_path = "../test-strategy"
}

inputs = {
  region = "us-central1"
  zone = "us-central1-a"
  name = "test-strategy"

  # HTTPS
  private_key_path = "path/to/private.key"
  certificate_path = "path/to/certificate"

  /*The first host_rule is the default*/
  host_path_rules = [
    {
      /*named_port or NE name*/
      # 2. Add the output of your instance module's Managed Instance Group for each host_path_rule
      instance_group = dependency.test-strategy.outputs.instance_group_manager.instance_group
      port_name = "http8202"
      host_rule = {
        host = ["strategy-qa-two-gcp.marketshare.com"]
        path_matcher = "p1"
      }
      path_matcher = {
        name = "p1"

        path_rule = [{
          paths = ["/*"]
        }]
      }
    }, {
    # 2. Add the output of your instance module's Managed Instance Group for each host_path_rule
    instance_group = dependency.test-strategy.outputs.instance_group_manager.instance_group
    port_name = "http8201"
    host_rule = {
      host = ["strategy-qa-six-gcp.marketshare.com"]
      path_matcher= "p2"
    }
    path_matcher = {
      name = "p2"

      path_rule = [{
        paths = ["/*"]
      }]
    }
  },{
    # 2. Add the output of your instance module's Managed Instance Group for each host_path_rule
    instance_group = dependency.test-strategy.outputs.instance_group_manager.instance_group
    port_name = "http8203"
    host_rule = {
      host = ["strategy-qa-one-gcp.marketshare.com"]
      path_matcher= "p3"
    }
    path_matcher = {
      name = "p3"

      path_rule = [{
        paths = ["/*"]
      }]
    }
  }]
}



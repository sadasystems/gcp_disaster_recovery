include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/load-balancer"
}

dependency "test-strategy-unmanaged-instance-group" {
  config_path = "../test-strategy-unmanaged-instance-group"
}

/* 1. Add your instance to be connected to the load balancer
dependency "vm_name" {
  config_path = "../vm_name"
}
*/

inputs = {
  region = "us-central1"
  zone = "us-central1-a"
  name = "test-strategy-unmanaged"

  # HTTPS
  private_key_path = "rootCA"
  certificate_path = "rootCSR.cert"

  /*The first host_rule is the default*/
  host_path_rules = [
    {
      /*named_port or NE name*/
      # 2. Add the output of your instance module's Managed Instance Group for each host_path_rule
      instance_group = dependency.test-strategy-unmanaged-instance-group.outputs.instance_group.id
      port_name = "https"
      host_rule = {
        host = ["*"]
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



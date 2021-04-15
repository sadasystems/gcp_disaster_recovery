include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../../../..//modules/load-balancer"
}

module "lb" {
  source = ""

}

inputs = {
  enable_loadbalancer = true
  loadbalancer_name = "test"

  # We can't identify which MIG should be behind of this LB
  managed_instance_groups = ["terraform1-dr-instance-group"]

  lb_health_check = {
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    request_path        = "/health"
    port                = 80
    # host                = string
    logging             = true
  }
}

variable "project" {type = string}
variable "enable_loadbalancer" {type = bool}
variable "loadbalancer_name" {type = string}

variable "service_account_impersonate" { type = string }

variable "managed_instance_groups" { type = list(string)}

variable "lb_health_check" { type = object({
  check_interval_sec  = number
  timeout_sec         = number
  healthy_threshold   = number
  unhealthy_threshold = number
  request_path        = string
  port                = number
  host                = optional(string)
  logging             = bool
}) }
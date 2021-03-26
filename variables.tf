variable "project" { type = string }
variable "service_account_impersonate" { type = string }
variable "service_account" {
  default = null
  type = object({
    email  = string
    scopes = set(string)
  })
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
}

variable "region" { type = string }
variable "zone" { type = string }
variable "source_vm" {
  description = "Name of the VM migrated from AWS to GCP"
  type        = string
  default     = ""
}

variable "instance_template_name" { type = string }
variable "startup_script" {
  description = "User startup script to run when instances spin up"
  default     = ""
}

variable "disks" {
  type = list(object({
    boot         = bool
    auto_delete  = bool
    disk_name    = string
    disk_size_gb = number
    disk_type    = string
    source_image = optional(string)
    type         = string
  }))
}

variable "external_ip_name" { type = string }

variable "snapshot" {
  type = object({
    name               = string
    hours              = number
    start_time         = string
    max_retention_days = number
  })
}

# Health check
variable "health_check" {
  type = object({
    name                = string
    type                = optional(string)
    initial_delay_sec   = optional(number)
    check_interval_sec  = number
    healthy_threshold   = number
    timeout_sec         = number
    unhealthy_threshold = number
    response            = optional(string)
    proxy_header        = optional(string)
    port                = number
    request             = optional(string)
    request_path        = string
  })
}

# Instance group manager
variable "igm_name" { type = string }
variable "igm_base_instance_name_prefix" { type = string }
variable "igm_initial_delay_sec" { type = number }

# Load-balancer
variable "enable_loadbalancer" { type = bool }
variable "loadbalancer_name" { type = string }
variable "lb_health_check" { type = object({
  check_interval_sec  = number
  timeout_sec         = number
  healthy_threshold   = number
  unhealthy_threshold = number
  request_path        = string
  port                = number
  host                = string
  logging             = bool
}) }
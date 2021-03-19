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
variable "machine_type" { type = string }

variable "instance_template_name" { type = string }
variable "startup_script" {
  description = "User startup script to run when instances spin up"
  default = ""
}

variable "disks" {
  type = list(object({
    boot         = bool
    auto_delete  = bool
    disk_name    = string
    disk_size_gb = number
    disk_type    = string
    source_image = string
    type         = string
  }))
}

variable "snapshot" {
  type = object({
    hours = number
    start_time = string
    max_retention_days = number
  })
}

variable "subnetwork_project" { type = string }
variable "subnetwork" { type = string }

# Health check
variable "health_check" {
  type = object({
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
variable "igm_zone" { type = string }
variable "igm_initial_delay_sec" { type = number }
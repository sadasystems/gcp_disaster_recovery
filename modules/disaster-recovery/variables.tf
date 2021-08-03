variable "project" { type = string }

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

variable "network_tag" { type = list(string) }
variable "named_ports" {
  type = list(object({
    name = string
    port = number
  }))
}

# Instance group manager
#variable "igm_name" { type = string }
variable "igm_initial_delay_sec" { type = number }

variable "startup_script" {
  description = "User startup script to run when instances spin up"
  default     = ""
}
variable "disk_type" { type = string }

variable "snapshot" {
  type = object({
    hours              = number
    start_time         = string
    max_retention_days = number
  })
}

# Health check
variable "http_health_check_enabled" { type = bool }
variable "health_check" {
  type = object({
    check_interval_sec  = number
    healthy_threshold   = number
    timeout_sec         = number
    unhealthy_threshold = number
    port                = number
    request_path        = string
  })
}


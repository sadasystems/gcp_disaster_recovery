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

variable "location" { type = string }
variable "instance_template_name" { type = string }
variable "machine_type" { type = string }

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

variable "subnetwork_project" { type = string }
variable "subnetwork" { type = string }

# Health check
variable "check_interval_sec" { type = number }
variable "timeout_sec" { type = number }
variable "healthy_threshold" { type = number }
variable "unhealthy_threshold" { type = number }
variable "hc_http_request_path" { type = string }
variable "hc_http_port" { type = number }

# Instance group manager
variable "igm_name" { type = string }
variable "igm_base_instance_name" { type = string }
variable "igm_zone" { type = string }
variable "igm_initial_delay_sec" { type = number }
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

variable "startup_script" {
  description = "User startup script to run when instances spin up"
  default     = ""
}

variable "metadata" { type = map(string) }
variable "labels" { type = map(string) }

variable "disks" {
  type = list(object({
    boot         = bool
    auto_delete  = bool
    disk_name    = string
    disk_size_gb = number
    disk_type    = string   #pd-ssd, local-ssd or pd-standard
    device_name = string
    labels = map(string)
    source_image = string
  }))
}

# Snapshot schedule
# https://cloud.google.com/compute/docs/disks/scheduled-snapshots
variable "snapshot" {
  type = object({
    hours              = number
    start_time         = string
    max_retention_days = number
  })
}

variable "subnetwork_project" {type =string}
variable "subnetwork" {type = string}

variable "vm_name" { type = string }
variable "machine_type" { type = string }

variable "network_tag" {
  type = list(string)
  default = null
}

variable "named_ports" {
  type = list(object({
    name = string
    port = number
  }))
}

/* Configuration for Disaster Recovery */
# Instance group manager
variable "igm_initial_delay_sec" { type = number }

# Health check for VM
# https://cloud.google.com/compute/docs/instance-groups/autohealing-instances-in-migs#example_health_check_set_up
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

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
  type = tuple([object({
    boot         = bool
    auto_delete  = bool
    disk_name    = string
    disk_size_gb = number
    disk_type    = string   #pd-ssd, local-ssd or pd-standard
    device_name = string
    labels = map(string)
    source_image = string
  })])
  default = [
    {
      boot = null
      auto_delete = null
      disk_name = null
      disk_size_gb = null
      disk_type = null
      device_name = null
      labels = null
      source_image = null
    }
  ]
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

variable "disk_type" {
  type = string
  default = "pd-ssd"
}

variable "subnetwork_project" {
  type =string
  default = null
}

variable "subnetwork" {
  type = string
  default = null
}

variable "vm_name" {
  type = string
  default = null
}

variable "machine_type" {
  type = string
  default = null
}

variable "source_vm" {
  description = "Name of the VM migrated from AWS to GCP"
  type        = string
  default     = ""
}

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
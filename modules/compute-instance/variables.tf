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
variable "subnetwork_project" {type =string}
variable "subnetwork" {type = string}

variable "vm_name" { type = string }
variable "machine_type" { type = string }
variable "allow_stopping_for_update" {type = bool}

variable "startup_script" {
  description = "User startup script to run when instances spin up"
  default     = ""
}
variable "boot_disk" {
  type = object({
    auto_delete = string
    device_name = string
    initialize_params = object({
      image = string
      size = number
      type = string
    })
    mode = optional(string)
    source = optional(string)
  })
}
variable "disks" {
  type = list(object({
    boot         = bool
    auto_delete  = bool
    disk_name    = string
    disk_size_gb = number
    disk_type    = string   #pd-ssd, local-ssd or pd-standard
    source_image = string
    type         = string  # SCRATCH or PERSISTENT
  }))
}

variable "snapshot" {
  type = object({
    hours              = number
    start_time         = string
    max_retention_days = number
  })
}

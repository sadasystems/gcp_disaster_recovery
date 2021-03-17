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
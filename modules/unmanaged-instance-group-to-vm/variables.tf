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

variable "zone" { type = string }

variable "source_vm" {
  description = "Name of the VM migrated from AWS to GCP"
  type        = string
  default     = ""
}

variable "port_name" { type = string }
variable "port_number" { type = string }

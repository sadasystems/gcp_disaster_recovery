variable "project" {
  type = string
}
variable "service_account" {
  type = string
}

variable "location" {
  type = string
}
# Variables for Instance template
variable "instance_template_name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "image_names" {
  type = list(string)
}

variable "subnetwork_project" {
  type = string
}

variable "subnetwork" {
  type = string
}
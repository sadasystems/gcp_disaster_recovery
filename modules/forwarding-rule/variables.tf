variable "project" { type = string }
variable "service_account_impersonate" { type = string }

variable "region" {type = string}
variable "zone" { type = string }
variable "name" {type =string}

/*
variable "network_interfaces" {
  type = list(object({
    network = string
    subnetwork = string
  }))
}
*/

variable "instance_group" { type = string }

variable "host_path_rules" {
  type = list(object({
    port_name = string
    host_rule = object({
      host = list(string)
      path_matcher = string
    })
    path_matcher = object({
      name = string

      path_rule = list(object({
        paths = list(string)
      }))
    })
  }))
}

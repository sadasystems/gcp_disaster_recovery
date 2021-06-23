variable "project" { type = string }
variable "service_account_impersonate" { type = string }

variable "region" {type = string}
variable "zone" { type = string }
variable "name" {type =string}

variable "private_key_path" { type = string}
variable "certificate_path" { type = string}

variable "host_path_rules" {
  type = list(object({
    instance_group = string
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

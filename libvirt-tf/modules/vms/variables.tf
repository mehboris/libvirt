variable "domain_name" {
  description = "domain_name"
  type        = string
}

variable "image_source" {
  description = "image_source"
  type        = string
}

variable "memory" {
  description = "memory"
  type        = number
}

variable "vcpu" {
  description = "vcpu"
  type        = number
}

variable "network_interfaces" {
  type = list(map(string))
}

variable "domain_name" {
  description = "domain_name"
  type        = string
}
variable "template_path" {
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


variable "network_id" {
  description = "domain_name"
  type        = string
}

variable "hostname" {
  description = "domain_name"
  type        = string
}

variable "addresses" {
  description = "domain_name"
  type        = string
  default = ""
}

variable "mac" {
  description = "domain_name"
  type        = string
  default = ""
}
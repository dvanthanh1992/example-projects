variable "resource_group_name" {
  description = "(Required) Specifies the name of the network security group"
  type        = string
}

variable "resource_group_location" {
  description = "(Required) Specifies the resource group name of the network security group"
  type        = string
}

variable "location" {
  description = "(Required) Specifies the location of the network security group"
  type        = string
}

variable "security_rules" {
  description = "(Optional) Specifies the security rules of the network security group"
  type        = list(object)
  default     = []
}

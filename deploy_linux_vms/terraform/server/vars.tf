variable "prefix" {
  description = "The prefix which should be used for all resources"
}

variable "tag_env" {
    description = "Environment tag"
    default     = "test"
}

variable "tag_task"{
    description = "Task tag"
    default     = "test"
}
variable "vm_count"{
    description = "Number of vms to create"
}
variable "location" {
  description = "The Azure Region in which all resources should be created."
  default = "westeurope"
}
variable "username" {
  description = "vm user name"
}
variable "password" {
  description = "vm password"
}
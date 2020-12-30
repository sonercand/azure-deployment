variable "prefix" {
  description = "The prefix which should be used for all resources"
  default = "test"
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
    default = 2
    validation {
     condition = var.vm_count<6
     error_message = "Number of virtual machines set are greater than 5, please refer to vars.tf file."
    }
}
variable "location" {
  description = "The Azure Region in which all resources should be created."
  default = "westeurope"
}
variable "username" {
  description = "vm user name"
  default = "a45ka"
}
variable "password" {
  description = "vm password"
  default = "adch34!3d$;1A"
}
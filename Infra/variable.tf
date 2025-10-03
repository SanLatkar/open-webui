variable "ami_type" {
  type = string
}

variable "instance_types" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "capacity_type" {
  type = string
}

variable "desired_nodegorup_size" {
  type = number
}

variable "k8_version" {
  type = string
}

variable "Name" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "domain_name" {
  type = string
}
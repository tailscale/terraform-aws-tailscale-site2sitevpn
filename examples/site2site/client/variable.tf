variable "subnet_id" {
  description = "Subnet ID to deploy the site to site instances to"
  type        = string
}

variable "name" {
  description = "Name of the site to site instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy the site to site instances to"
  type        = string
}

variable "ssh_key_content" {
  description = "SSH Key content to use for the site to site instance"
  type        = string
}

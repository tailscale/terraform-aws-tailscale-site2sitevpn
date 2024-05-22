variable "subnet_id" {
  description = "Subnet ID to deploy the site to site instances to"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy the site to site instances to"
  type        = string
}

variable "advertise_addresses" {
  description = "Addresses to advertise for the site to site instance"
  type        = list(string)
}

variable "remote_addresses" {
  description = "Address to connect to for the site to site instance"
  type        = list(string)
}

variable "name" {
  description = "Name of the site to site instance"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the site to site instance"
  type        = map(string)
  default     = {}
}

variable "architecture" {
  description = "Architecture of the instance"
  type        = string
  default     = "x86_64"
}

variable "instance_type" {
  description = "Instance type to use for the site to site instance"
  default     = "t3.medium"
  type        = string
}

variable "ebs_root_volume_size" {
  description = "Size of the root volume in GB"
  default     = 20
  type        = number
}

variable "enable_aws_ssm" {
  description = "Whether to attach the minimum required IAM permissions to connect to the instance via SSM."
  type        = bool
  default     = true
}

variable "route_table_ids" {
  description = "Route table IDs to route traffic for the site to site instance"
  type        = list(string)
}

variable "tailscale_auth_key" {
  description = "Tailscale authentication key"
  type        = string
  sensitive   = true
}

variable "advertise_tags" {
  description = "Tags to advertise for the site to site instance"
  type        = list(string)
  default     = []
}

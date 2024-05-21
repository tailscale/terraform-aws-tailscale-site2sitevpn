variable "tailscale_auth_key" {
  description = "Tailscale Auth Key"
  type = string
  sensitive = true
}

variable "ssh_key_content" {
    description = "SSH Key content to use for the site to site instance"
    type = string
}
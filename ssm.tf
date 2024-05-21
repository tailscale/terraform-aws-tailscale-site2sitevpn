resource "aws_ssm_parameter" "tailnet_key" {
  name  = "tailnet-key-${var.name}"
  type  = "SecureString"
  value = var.tailscale_auth_key
}
data "cloudinit_config" "main" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "kernel.sh"
    content_type = "text/x-shellscript"

    content = file("${path.module}/files/kernel.sh")
  }

  part {
    filename     = "ssm.sh"
    content_type = "text/x-shellscript"

    content = file("${path.module}/files/ssm.sh")
  }

  part {
    filename     = "tailscale.sh"
    content_type = "text/x-shellscript"

    content = templatefile("${path.module}/templates/tailscale.sh.tmpl", {
      AWS_SSM_PARAM_NAME = aws_ssm_parameter.tailnet_key.name
      ADVERTISE_ROUTES   = join(",", var.advertise_addresses)
      ADVERTISE_TAGS     = join(",", var.advertise_tags)
      HOSTNAME           = var.name
      TAILSCALE_SSH      = var.enable_tailscale_ssh
    })
  }

  part {
    filename     = "network.sh"
    content_type = "text/x-shellscript"

    content = templatefile("${path.module}/templates/network.sh.tmpl", {
      ENI_ID   = aws_network_interface.main.id
      HOSTNAME = var.name
    })
  }


}

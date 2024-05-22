resource "aws_iam_instance_profile" "main" {
  name = var.name
  role = aws_iam_role.main.name
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "SessionManager"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenDataChannel",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:OpenControlChannel",
      "ssm:UpdateInstanceInformation",
    ]
    resources = [
      aws_instance.main.arn,
    ]

  }
}

resource "aws_iam_policy" "main" {
  name        = var.name
  description = "Policy for ${var.name}"
  policy      = data.aws_iam_policy_document.main.json
}

resource "aws_iam_role" "main" {
  name = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })



}

resource "aws_security_group" "main" {
  name        = var.name
  description = "Security group"
  vpc_id      = var.vpc_id

  #checkov:skip=CKV_AWS_277:Testing instance
  #checkov:skip=CKV_AWS_25:Testing instance
  #checkov:skip=CKV_AWS_24:Testing instance
  #checkov:skip=CKV_AWS_260:Testing instance
  ingress {
    description      = "Allow all traffic to the instance for testing purposes"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Unrestricted egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

data "aws_ami" "main" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*"]
  }
}

resource "aws_key_pair" "main" {
  key_name   = var.name
  public_key = var.ssh_key_content
}

data "cloudinit_config" "main" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "ssm.sh"
    content_type = "text/x-shellscript"

    content = file("${path.module}/files/ssm.sh")
  }



}


resource "aws_instance" "main" {
  ami                    = data.aws_ami.main.id
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.main.name
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  user_data_base64       = data.cloudinit_config.main.rendered

  ebs_optimized = true

  tags = {
    Name = var.name
  }

  root_block_device {
    encrypted = true
  }

  monitoring = true
  lifecycle {
    create_before_destroy = true
  }

  # Enforce IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

}

resource "aws_iam_policy_attachment" "main" {
  name       = var.name
  policy_arn = aws_iam_policy.main.arn
  roles      = [aws_iam_role.main.name]
}

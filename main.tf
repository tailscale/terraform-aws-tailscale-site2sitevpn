resource "aws_autoscaling_group" "main" {
  name                = var.name
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  health_check_type   = "EC2"
  vpc_zone_identifier = [var.subnet_id]

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_security_group" "main" {
  name        = var.name
  description = "Used in ${var.name} instance of subnet-router in subnet ${var.subnet_id}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.advertise_addresses
    content {
      description = "Allow local traffic from ${ingress.value} to the site to site instance"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [ingress.value]
    }
  }

  ingress {
    description = "Allow remote subnet traffic from the VPC to the site to site instance"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.remote_address]
  }

  egress {
    description      = "Unrestricted egress"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_network_interface" "main" {
  description       = "${var.name} reusable ENI for routing traffic between sites"
  subnet_id         = var.subnet_id
  security_groups   = [aws_security_group.main.id]
  
  source_dest_check = false

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_eip" "main" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.main.id
   tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route" "main" {
  for_each = toset(var.route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = var.remote_address
  network_interface_id   = aws_network_interface.main.id
}

resource "aws_route" "tailnet" {
  for_each = toset(var.route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = "100.64.0.0/10"
  network_interface_id   = aws_network_interface.main.id
}
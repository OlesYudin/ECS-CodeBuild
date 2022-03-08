resource "aws_security_group" "sg" {
  name        = "Security-group"
  description = "Security group for ECS"
  vpc_id      = aws_vpc.vpc.id

  # Inbound rules for 22,80,8080 ports
  # Open 22 to my IP and my VPC
  # Open 80, 8080 to all in the Internet
  dynamic "ingress" {
    for_each = var.sg_port_cidr
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value
    }
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "SG-${var.env}-ECS"
    Environment = var.env
  }
}

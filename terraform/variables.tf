variable "region" {
  default = "us-east-2"
}
variable "profile" {
  default = "student"
}
variable "env" {
  default = "dev"
}
# SG

# Inbound/Outbound rules of Security group thats open port to CIDR like key --> value
variable "sg_port_cidr" {
  description = "Allowed EC2 ports"
  type        = map(any)
  default = {
    "80" = ["0.0.0.0/0"]
  }
}

# VPC
variable "cidr_vpc" {
  description = "CIDR of VPC"
  type        = string
  default     = "10.10.0.0/16"
}
# Public Subnet
variable "public_subnet" {
  type = list(string)
  default = [
    "10.10.1.0/24",
    "10.10.2.0/24"
  ]
}

# EC2
variable "app_name" {
  default = "password_generator"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "app_port" {
  default = 80
}

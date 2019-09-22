variable "certificate_email" {}
variable "ami" {
  default = "ami-07a8d85046c8ecc99" // AMI bitnami de wordpress, debes cambiarla segun tu región
}

variable "route53_zone_name" {}
variable "subdomain_name" {}
variable "instance_type" {
  default = "t2.micro"
}
variable "namespace" {}
variable "vpc_id" {}

variable "ssh_cidr" {
  default = "0.0.0.0/0"
}


variable "ssh_user" {
  default = "bitnami"
}
variable "public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
    default = "~/.ssh/id_rsa"
}

variable "region" {
  default = "us-east-1"
}


variable "subnet_id" {
  
}

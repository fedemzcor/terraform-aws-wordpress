resource "aws_instance" "wp" {
  tags = {
    Name = "${var.namespace}-wp"
  }

  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.wp.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = ["${aws_security_group.wp.id}"]
  associate_public_ip_address = false

}

resource "aws_eip" "wp" {

  depends_on = [
    "aws_instance.wp"
  ]
  instance = "${aws_instance.wp.id}"
  vpc      = true
}


resource "aws_route53_record" "domain" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${var.subdomain_name}"
  type    = "A"
  ttl     = 60
  records = ["${aws_eip.wp.public_ip}"]
}

resource "aws_key_pair" "wp" {
  key_name   = "${var.namespace}-wp-key"
  public_key = "${file(var.public_key)}"
}



resource "aws_security_group" "wp" {
  name        = "${var.namespace}-wp-sg"
  description = "Allow traffic needed by ${var.namespace}-wp"
  vpc_id      = "${var.vpc_id}"

  // ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_cidr}"]
  }

  // http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // https
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }
  

  // all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "null_resource" "provision_wp" {
  triggers = {
    subdomain_id = "${aws_route53_record.domain.id}"
  }
  
  connection {
    type        = "ssh"
    host        = "${aws_eip.wp.public_ip}"
    user        = "${var.ssh_user}"
    port        = 22
    private_key = "${file(var.private_key)}"
    agent       = false
  }

  provisioner "file" {
    source      = "./script.sh"
    destination = "/home/bitnami/script.sh"
  }


  provisioner "remote-exec" {

    inline = [
      "sleep 440",
      "chmod +x /home/bitnami/script.sh",
      "sh /home/bitnami/script.sh ${var.certificate_email} ${var.subdomain_name}",
    ]
  }
  
}


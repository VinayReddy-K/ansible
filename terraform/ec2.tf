resource "aws_instance" "ansible" {
  count                     = local.LENGTH
  ami                       = "ami-0e4e4b2f188e91845"
  instance_type             = "t2.micro"
  vpc_security_group_ids    = ["sg-0ce90bc6ff22f0a2c"]
  tags                      = {
    Name                    = element(var.COMPONENTS, count.index)
  }
}

resource "aws_route53_record" "records" {
  count                     = local.LENGTH
  name                      = "${element(var.COMPONENTS, count.index)}-${var.ENV}"
  type                      = "A"
  zone_id                   = "Z05588222UV008VFLU0F0"
  ttl                       = 300
  records                   = [element(aws_instance.ansible.*.private_ip, count.index)]
}

locals {
  LENGTH    = length(var.COMPONENTS)
}

##COMPONENTS = ["mysql", "mongodb", "rabbitmq", "redis", "cart", "catalogue", "user", "shipping", "payment", "frontend"]
output "attributes" {
  value = aws_instance.ansible.*.private_ip
}

resource "local_file" "ansible" {
  content         = "[FRONTEND]\n${aws_instance.ansible.*.private_ip[9]}\n[PAYMENT]\n${aws_instance.ansible .*.private_ip[8]}\n[SHIPPING]\n${aws_instance.ansible.*.private_ip[7]}\n[USER]\n${aws_instance   .ansible.*.private_ip[6]}\n[CATALOGUE]\n${aws_instance.ansible.*.private_ip[5]}\n[CART]\n${aws_instance.ansible.*.private_ip[4]}\n[REDIS]\n${aws_instance.ansible.*.private_ip[3]}\n[RABBITMQ]\n${aws_instance.ansible.*.private_ip[2]}\n[MONGODB]\n${aws_instance.ansible.*.private_ip[1]}\n[MYSQL]\n${aws_instance.ansible.*.private_ip[0]}"
  filename        = "/tmp/inv-roboshop-${var.ENV}"
}

 
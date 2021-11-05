#resource "aws_instance" "ansible" {
#  count                     = local.LENGTH
#  ami                       = "ami-0dc863062bc04e1de"
#  instance_type             = "t2.micro"
#  vpc_security_group_ids    = ["sg-0ce90bc6ff22f0a2c"]
#  tags                      = {
#    Name                    = "${element(var.COMPONENTS, count.index)}-${var.ENV}"
#  }
#}

resource "aws_instance" "app-instances" {
  count                     = length(var.APP_COMPONENTS)
  ami                       = "ami-0dc863062bc04e1de"
  instance_type             = "t2.micro"
  vpc_security_group_ids    = ["sg-0ce90bc6ff22f0a2c"]
  tags                      = {
    Name                    = "${element(var.APP_COMPONENTS, count.index)}-${var.ENV}"
    Monitor                 = "yes"
  }
}

resource "aws_instance" "db-instances" {
  count                     = length(var.DB_COMPONENTS)
  ami                       = "ami-0dc863062bc04e1de"
  instance_type             = "t2.micro"
  vpc_security_group_ids    = ["sg-0ce90bc6ff22f0a2c"]
  tags                      = {
    Name                    = "${element(var.DB_COMPONENTS, count.index)}-${var.ENV}"
  }
}

#resource "aws_route53_record" "app-records" {
#  count                     = local.LENGTH
#  name                      = "${element(var.COMPONENTS, count.index)}-${var.ENV}"
#  type                      = "A"
#  zone_id                   = "Z05588222UV008VFLU0F0"
#  ttl                       = 300
#  records                   = [element(aws_instance.ansible.*.private_ip, count.index)]
#}


resource "aws_route53_record" "app-records" {
  count                     = length(var.APP_COMPONENTS)
  name                      = "${element(var.APP_COMPONENTS, count.index)}-${var.ENV}"
  type                      = "A"
  zone_id                   = "Z05588222UV008VFLU0F0"
  ttl                       = 300
  records                   = [element(aws_instance.app-instances.*.private_ip, count.index)]
}

resource "aws_route53_record" "db-records" {
  count                     = length(var.DB_COMPONENTS)
  name                      = "${element(var.DB_COMPONENTS, count.index)}-${var.ENV}"
  type                      = "A"
  zone_id                   = "Z05588222UV008VFLU0F0"
  ttl                       = 300
  records                   = [element(aws_instance.db-instances.*.private_ip, count.index)]
}


#locals {
#  LENGTH    = length(var.COMPONENTS)
#}

locals {
  COMPONENT = concat(aws_instance.db-instances.*.private_ip,aws_instance.app-instances.*.private_ip)
}

##COMPONENTS = ["mysql", "mongodb", "rabbitmq", "redis", "cart", "catalogue", "user", "shipping", "payment", "frontend"]
#output "attributes" {
#  value = aws_instance.ansible.*.private_ip
#}

resource "local_file" "ansible" {
  content         = "[FRONTEND]\n${local.COMPONENT[9]}\n[PAYMENT]\n${local.COMPONENT[8]}\n[SHIPPING]\n${local.COMPONENT[7]}\n[USER]\n${local.COMPONENT[6]}\n[CATALOGUE]\n${local.COMPONENT[5]}\n[CART]\n${local.COMPONENT[4]}\n[REDIS]\n${local.COMPONENT[3]}\n[RABBITMQ]\n${local.COMPONENT[2]}\n[MONGODB]\n${local.COMPONENT[1]}\n[MYSQL]\n${local.COMPONENT[0]}"
  filename        = "/tmp/inv-roboshop-${var.ENV}"
}
#

 
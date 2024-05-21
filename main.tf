#creating local name for my resources
locals {
  name = "row"
}
#creating pvc 
resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "${local.name}-vpc"
  }
}
//creating pub_subnets
resource "aws_subnet" "sub1" {
  availability_zone = var.az1
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr2

  tags = {
    Name = "${local.name}-sub1"
  }
}

resource "aws_subnet" "sub2" {
  availability_zone = var.az2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr3

  tags = {
    Name = "${local.name}-sub2"
  }
}

//creating private subnets
//resource "aws_subnet" "prisub1" {
  //availability_zone = var.az1
  //vpc_id            = aws_vpc.vpc.id
  //cidr_block        = var.cidr4

 // tags = {
 //   Name = "${local.name}-prisub1"
 // }
//}

//resource "aws_subnet" "prisub2" {
 // availability_zone = var.az2
 // vpc_id            = aws_vpc.vpc.id
 // cidr_block        = var.cidr5

 // tags = {
  //  Name = "${local.name}-prisub2"
 // }
//}

#creating internet_gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name}-gw"
  }
}

//creating nat gateway
//resource "aws_nat_gateway" "nat" {
// connectivity_type = "private"
// subnet_id         = aws_subnet.prisub1.id
//}

//creating elastic ip
#resource "aws_eip" "elastic_ip"{
#domain= "vpc"
#depends_on =[aws_nat_gateway.nat]
# tags= {
#Name= "$(local.name)-eip" 
#}
#}

#creating pub_route_table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.allcidr
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${local.name}-rt"
  }
}

#creating private_route_table
//resource "aws_route_table" "prirt" {
// vpc_id = aws_vpc.vpc.id

// route {
//   cidr_block = var.cidr4
//   gateway_id = aws_nat_gateway.nat.id
// }
// tags = {
//   Name = "${locals.name}-prirt"
// }
//}

#creating route_table_association 
resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

#creating route_table_association2 
resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}

#creating private route_table_association2 
//resource "aws_route_table_association" "prirt" {
// subnet_id      = aws_subnet.prisub1.id
//route_table_id = aws_route_table.prirt.id
//}

#creating private route_table_association2 
//resource "aws_route_table_association" "prirt2" {
//subnet_id      = aws_subnet.prisub2.id
//route_table_id = aws_route_table.prirt.id
//}

//creating security_group
resource "aws_security_group" "sg" {
  name        = "ansible-sg allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "ssh from vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }
  tags = {
    Name = "${local.name}-sg"
  }
}

resource "aws_security_group" "sg2" {
  name        = "instance allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "ssh from vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  ingress {
    description = "ssh from vpc"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }

  tags = {
    Name = "${local.name}-sg2"
  }
}

#creating keypair
resource "aws_key_pair" "key" {
  key_name   = "${local.name}-keypair"
  public_key = file(var.keypair)
}

//creating instance

resource "aws_instance" "ansible" {
  ami                         = var.ubuntu //ansible ubuntu ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.sub1.id
  associate_public_ip_address = true
  user_data                   = file("./userdata.sh")
  tags = {
    Name = "${local.name}-ansible"
  }
}

resource "aws_instance" "redhat" {
  ami                         = var.redhat //redhat ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.sg2.id]
  subnet_id                   = aws_subnet.sub1.id
  associate_public_ip_address = true
  tags = {
    Name = "${local.name}-redhat"
  }
}

resource "aws_instance" "ubuntu" {
  ami                         = var.ubuntu //ubuntu ami
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.sg2.id]
  subnet_id                   = aws_subnet.sub1.id
  associate_public_ip_address = true
  tags = {
    Name = "${local.name}-ubuntu"
  }
}



# Get Availability zones in the Region
data "aws_availability_zones" "AZ" {}

# Get My Public IP
data "http" "my_public_ip" {
  url = "https://ipinfo.io/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  public_ip = jsondecode(data.http.my_public_ip.body).ip
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "tf-example-2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet
  availability_zone       = data.aws_availability_zones.AZ.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet"
  }
}

resource "aws_network_interface" "network_interface" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = [var.private_ip]
  security_groups = [aws_security_group.splunk_sg.id]
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_main_route_table_association" "association" {
  vpc_id         = aws_vpc.my_vpc.id
  route_table_id = aws_route_table.public.id
}

output "splunk_default_username" {
  value = "admin"
}

resource "aws_security_group" "splunk_sg" {
  name        = "Splunk SG"
  description = "Splunk Security Group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "API Access"
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["${local.public_ip}/32"]
  }
  ingress {
    description = "UI Access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["${local.public_ip}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ### To be more accurate, we could specify the Terraform Cloud public IP ranges used for API communications. Uncomment the line below and the ip_ranges datasource and public_ip_range locals if required.
    //cidr_blocks      = local.public_ip_range.api

    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "splunk_sg"
  }
}

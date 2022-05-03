variable "region" { default = "us-west-2" }
variable "availability_zone" { default = "us-west-2a" }
variable "instance_type" { default = "t2.micro" }
variable "private_ip" { default = "172.16.10.100" }
variable "subnet" { default = "172.16.10.0/24" }
variable "vpc_cidr" { default = "172.16.0.0/16" }
variable "ami" { default = "ami-0ca285d4c2cda3300"}

locals {
    configuration  = [
    {
        "application_name" : "splunk-mgmt-ds",
        "ami" : var.ami,
        "no_of_instances" : "1",
        "instance_type" : var.instance_type,
        "subnet_id" :  aws_subnet.my_subnet.id,
        "vpc_security_group_ids" : [aws_security_group.splunk_sg.id]
    },
    {
      "application_name" : "splunk-mgmt-cm",
      "ami" : var.ami,
      "instance_type" : var.instance_type,
      "no_of_instances" : "1"
      "subnet_id" :  aws_subnet.my_subnet.id,
      "vpc_security_group_ids" : [aws_security_group.splunk_sg.id]
    },
    {
      "application_name" : "splunk-mgmt-lm",
      "ami" : var.ami,
      "instance_type" : var.instance_type,
      "no_of_instances" : "1"
      "subnet_id" :  aws_subnet.my_subnet.id,
      "vpc_security_group_ids" : [aws_security_group.splunk_sg.id]
    },
      {
      "application_name" : "splunk-mgmt-mc",
      "ami" : var.ami,
      "instance_type" : var.instance_type,
      "no_of_instances" : "1"
      "subnet_id" :  aws_subnet.my_subnet.id,
      "vpc_security_group_ids" : [aws_security_group.splunk_sg.id]
    },
    {
      "application_name" : "splunk-search-cluster",
      "ami" : var.ami,
      "instance_type" : var.instance_type,
      "no_of_instances" : "3"
      "subnet_id" :  aws_subnet.my_subnet.id,
      "vpc_security_group_ids" : [aws_security_group.splunk_sg.id]
    },
    {
      "application_name" : "splunk-index-cluster",
      "ami" : var.ami,
      "instance_type" : var.instance_type,
      "no_of_instances" : "3"
      "subnet_id" :  aws_subnet.my_subnet.id,
      "vpc_security_group_ids" : [aws_security_group.splunk_sg.id]
    }
 ]
}
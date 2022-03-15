terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  key_name= "aws_key"
  vpc_security_group_ids = [aws_security_group.main.id]
  tags = {
    Name = "ExampleAppServerInstance"
  }
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("../.keys/id_rsa")
      timeout     = "4m"
   }
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  },
     {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 80
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 80
  }
  ]
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClQ0OtERE2w/lWpQ5xPv5ooTWy1QHT0emggDk5I8w3RDm1GQE7zjZbfUXlIxGnWzTifPxoMszAVtOuF43guSzE2pWj3hGriGofer6I0a6gV7eYWaBJoQDmaCVjkY8eqOduX1v+f8noIyGHwYfc5tdaGEetHVx2O6Fx1ILB/b9WNdJk/L03B6WkjpXiytVvtMcbJtZWixflw+bF+Kdy1IyOX4AUrBN/+aQeoosaLuDkLFwWeHRyRL2q3xPPCjL74I4pDLeQ+jTu4qvsLtVxbFoBBLoIzbMFdTh4mAkuefErwiGBSlMBhj5AIApKG63rPKJ3+dS2QHEAwoBZ5cTNoU4nVh1sjr4WzUIXa3PU5EUJWAjByg/ZNL2qCk9yGE+jjiqhJ2M8Y6dUYfZXlRXvSiyp9AGaPKvg+MrI+9ttNdSi4eaFPRy7cujno3wZ0aO6S6QvUuE7dQegJ+GXILKkebXlkI/R4k0spR5HKJlqPTBRX7ISH7VSW+lhoFeUrMbxqFk= jon@DESKTOP-TD4TO2R"
}
variable "ami_id" {
  type = string
}

variable "region" {
  description = "The AWS region to use for resources"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

data "aws_security_group" "selected" {
  id = "sg-037fd498b332442c1"
}

resource "aws_instance" "test" {
  ami           = var.ami_id
  instance_type = "t2.small"
  tags = {
    Name = "aws-packer-testing-instance"
  }
  vpc_security_group_ids = [data.aws_security_group.selected.id]

  provisioner "local-exec" {
    command = "aws ec2 deregister-image --image-id ${self.ami}"
    when    = destroy

    environment = {
      AWS_REGION = "us-east-1"
    }
  }
}

output "public_ip_address" {
  value = aws_instance.test.public_ip
}

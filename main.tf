terraform {
  backend "s3" {
    bucket = "packer-terraform-github-actions"
    region = "us-east-1"
    key    = "myapp.state"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "myami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["myami*"]
  }

}

resource "aws_security_group" "http" {
  name = "http"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "http"
  }
}

resource "aws_instance" "test" {
  ami                    = data.aws_ami.myami.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http.id]
}

output "ip" {
  value = aws_instance.test.public_id
}

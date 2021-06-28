packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "linux" {
  ami_name      ="myami-${formatdate("YYYYMMDDhhmm", timeadd(timestamp(), "-3h"))}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  tags          = {
    name = "packer-terraform-github-actions"
  }
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}


build {
  sources = [
    "source.amazon-ebs.linux"
  ]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo pip3 install uvicorn",
      "sudo pip3 install fastapi",
      "sudo pip3 install requests",
      "mkdir app"
    ]
  }

  provisioner "file" {
    source      = "main.py"
    destination = "app/main.py"
  }

  provisioner "file" {
    source      = "myapp.sh"
    destination = "app/myapp.sh"
  }

  provisioner "file" {
    source      = "myapp.service"
    destination = "app/myapp.service"
  }

  provisioner "shell" {
    inline = [
      "sudo cp app/myapp.sh /usr/local/bin",
      "sudo chmod +x /usr/local/bin/myapp.sh",
      "sudo cp app/myapp.service /etc/systemd/system",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable myapp",
      "sudo systemctl start myapp"
    ]
  }

}
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "redis" {
  ami_name      = "redis-server"
  instance_type = "t4g.micro"
  region        = "us-east-1"
  source_ami    = "ami-029c64b3c205e6cce"
  ssh_username  = "ec2-user"
}

build {
  name = "redis"
  sources = [
    "source.amazon-ebs.redis"
  ]

  provisioner "shell" {
    script = "./install-redis.sh"
  }
}

packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}

source "digitalocean" "redis" {
  region        = "nyc3"
  size          = "s-1vcpu-1gb"
  image         = "ubuntu-20-04-x64"
  snapshot_name = "redis-server"
  ssh_username  = "root"
}

build {
  name = "redis"
  sources = [
    "source.digitalocean.redis"
  ]
}

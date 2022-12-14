packer {
  required_plugins {
    amazon = {
      version = "= 1.1.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  region  = "us-east-1"
  project = "buichadon-ubuntu"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = local.project
  instance_type = "t2.micro"
  region        = local.region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username          = "ubuntu"
  force_deregister      = true
  force_delete_snapshot = true
}

build {
  name = "buichadon-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    use_proxy     = false
  }
}

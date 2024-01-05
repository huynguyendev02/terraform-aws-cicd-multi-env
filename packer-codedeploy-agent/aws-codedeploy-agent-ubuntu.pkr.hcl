packer {
	required_plugins {
		amazon = {
			version = ">= 0.0.1"
			source = "github.com/hashicorp/amazon"
		}
	}
}

source "amazon-ebs" "codedeploy-agent" {
  ami_name      = "${var.ami_name}-{{timestamp}}"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  source_ami = "${var.source_ami_name}"
  ssh_username = "${var.ssh_username}"
  tags = {
    Name = "ami-${var.project_name}"
    OS_Version = "Ubuntu"
    Release = "22.04"
    Project = var.project_tag
    Owner = var.owner_tag
  }
}

build {
  name    = "codedeploy-agent-ubuntu-build"
  sources = [
    "source.amazon-ebs.codedeploy-agent"
  ]
  provisioner "shell" {
    scripts = [
      "./scripts/install-codedeploy.sh",
      "./scripts/install-docker.sh",
      "./scripts/install-aws.sh",
      "./scripts/install-convert-json-env.sh"
    ]
  }
}
variables {
  aws_security_group_id = "sg-037fd498b332442c1"
  image_name            = "poc-packer-meilisearch"
  base-os-version       = "Debian-10.3"
}

variable "meilisearch_version" {
  type    = string
  default = "v1.1.1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "debian" {
  ami_name        = "${var.image_name}-${var.meilisearch_version}-${var.base-os-version}-${local.timestamp}"
  instance_type   = "t2.small"
  region          = "us-east-1"
  ami_description = "MeiliSearch-${var.meilisearch_version} running on in ${var.base-os-version}"
  source_ami_filter {
    filters = {
      name                = "debian-10-amd64*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"]
  }
  security_group_id = "${var.aws_security_group_id}"
  ssh_username      = "admin"
}

build {
  sources = [
    "source.amazon-ebs.debian"
  ]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E '{{ .Path }}'"
    script          = "scripts/nginx.sh"
  }

  provisioner "file" {
    source      = "config/meilisearch.service"
    destination = "/tmp/meilisearch.service"
  }

  provisioner "file" {
    source      = "config/nginx-meilisearch"
    destination = "/tmp/nginx-meilisearch"
  }

  provisioner "file" {
    source      = "scripts/first-login/000-set-meili-env.sh"
    destination = "/tmp/000-set-meili-env.sh"
  }

  provisioner "file" {
    source      = "scripts/first-login/001-setup-prod.sh"
    destination = "/tmp/001-setup-prod.sh"
  }

  provisioner "file" {
    source      = "MOTD/99-meilisearch-motd"
    destination = "/tmp/99-meilisearch-motd"
  }

  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apt-get update -y -q",
      "mv /tmp/meilisearch.service /etc/systemd/system/meilisearch.service",
      "sed -i 's/provider_name/${source.type}/' /etc/systemd/system/meilisearch.service",
      "mv /tmp/nginx-meilisearch /etc/nginx/sites-enabled/meilisearch",
      "mkdir -p /var/opt/meilisearch/scripts/first-login",
      "chmod +x /var/opt/meilisearch/scripts/first-login",
      "mv /tmp/000-set-meili-env.sh /var/opt/meilisearch/scripts/first-login/000-set-meili-env.sh",
      "sed -i 's/provider_name/${source.type}/' /var/opt/meilisearch/scripts/first-login/000-set-meili-env.sh",
      "mv /tmp/001-setup-prod.sh /var/opt/meilisearch/scripts/first-login/001-setup-prod.sh",
      "mv /tmp/99-meilisearch-motd /etc/update-motd.d/99-meilisearch-motd",
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "MEILISEARCH_VERSION=${var.meilisearch_version}",
      "MEILISEARCH_ENV_PATH=/var/opt/meilisearch/env",
    ]
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E '{{ .Path }}'"
    script          = "scripts/meilisearch-install.sh"
  }
}

variables {
  aws_security_group_id = "sg-037fd498b332442c1"
  image_name            = "Meilisearch"
  base-os-version       = "Debian-11"
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
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
    digitalocean = {
      version = ">= 1.0.4"
      source  = "github.com/digitalocean/digitalocean"
    }
    googlecompute = {
      version = ">= 1.1.1"
      source = "github.com/hashicorp/googlecompute"
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
      name                = "debian-11-amd64*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"]
  }
  security_group_id = "${var.aws_security_group_id}"
  ssh_username      = "admin"
}

source "digitalocean" "debian" {
  // you need the env variable DIGITALOCEAN_ACCESS_TOKEN locally
  droplet_name = "${var.image_name}-${var.meilisearch_version}-${var.base-os-version}-${local.timestamp}"
  snapshot_name= "${var.image_name}-${var.meilisearch_version}-${var.base-os-version}-${local.timestamp}"
  image        = "debian-11-x64"
  region       = "lon1"
  size         = "s-1vcpu-2gb"
  ssh_username = "root"
  tags = [
    "MARKETPLACE",
    "AUTOBUILD",
  ]
}

source "googlecompute" "debian" {
  //TODO: The image name has to be fixed
  // image_name = "${var.image_name}-${var.meilisearch_version}-${var.base-os-version}-${local.timestamp}"
  project_id = "meilisearchimage"
  source_image = "debian-11-bullseye-v20230411"
  ssh_username = "packer"
  machine_type = "e2-small"
  zone = "us-central1-a"
}

build {
  sources = [
    "source.amazon-ebs.debian",
    "source.digitalocean.debian",
    "sources.googlecompute.debian"
  ]

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
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E '{{ .Path }}'"
    script          = "scripts/nginx.sh"
  }

  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
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

  provisioner "shell" {
    inline = [
      "apt-get install -y curl",
      "curl https://raw.githubusercontent.com/digitalocean/marketplace-partners/master/scripts/90-cleanup.sh | bash",
      "apt-get purge droplet-agent* -y",
      "curl https://raw.githubusercontent.com/digitalocean/marketplace-partners/master/scripts/99-img-check.sh | bash",
    ]
    only = ["digitalocean.debian"]
  }
}

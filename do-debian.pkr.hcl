variables {
  image_name            = "poc-packer-meilisearch"
  base-os-version       = "Debian-10.3"
}

packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.4"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

variable "meilisearch_version" {
  type    = string
  default = "v1.1.1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "digitalocean" "debian" {
  // you need the env variable DIGITALOCEAN_ACCESS_TOKEN locally
  image        = "debian-10-x64"
  region       = "lon1"
  size         = "s-1vcpu-2gb"
  ssh_username = "root"
  droplet_name = "${var.image_name}-${var.meilisearch_version}-${var.base-os-version}-${local.timestamp}"
  snapshot_name= "${var.image_name}-${var.meilisearch_version}-${var.base-os-version}-${local.timestamp}"
  tags = [
    "MARKETPLACE",
    "AUTOBUILD",
  ]
}

build {
  sources = [
    "source.digitalocean.debian"
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

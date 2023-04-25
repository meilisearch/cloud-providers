#!/usr/bin/env bash

# Only needed on debian
export DEBIAN_FRONTEND=noninteractive

# Update APT cache
apt-get update -y -q

# Install packages
apt-get install -y nginx ufw certbot python3-certbot-nginx

# Remove the default virtualhost symlink
rm /etc/nginx/sites-enabled/default

# Firewall config --force disable the prompt for enabled it under ssh
ufw --force enable

# Allow nginx
ufw allow 'Nginx Full'

# Allow Openssh
ufw allow 'OpenSSH'

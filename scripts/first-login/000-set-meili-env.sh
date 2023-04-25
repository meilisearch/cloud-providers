#!/bin/bash


# This script will be installed in /var/opt/meilisearch/scripts/first-login
# and will be run automatically when user logs via ssh

GREEN="\033[32;11m"
BLUE="\033[34;11m"
YELLOW="\033[33;11m"
RED="\033[31;11m"
BOLD="\033[1m"
RESET="\033[0m"

echo "\n\nThank you for using$BLUE Meilisearch.$RESET\n\n"
echo "This script will help you to set up some basic configuration.\n"

MEILISEARCH_ENVIRONMENT='development'
MEILISEARCH_SERVER_PROVIDER=provider_name
USE_API_KEY='false'
MEILISEARCH_MASTER_KEY=''
MEILI_DUMP_DIR='/var/opt/meilisearch/dumps'
DOMAIN_NAME=''
USE_SSL='false'
USE_CERTBOT='false'

if test -f '/var/opt/meilisearch/env'; then
    . /var/opt/meilisearch/env
fi 

exit_with_message() {

    echo 'export MEILISEARCH_ENVIRONMENT='$MEILISEARCH_ENVIRONMENT > /var/opt/meilisearch/env
    echo 'export USE_API_KEY='$USE_API_KEY >> /var/opt/meilisearch/env
    echo 'export MEILISEARCH_MASTER_KEY='$MEILISEARCH_MASTER_KEY >> /var/opt/meilisearch/env
    echo 'export MEILI_DUMP_DIR='$MEILI_DUMP_DIR >> /var/opt/meilisearch/env
    echo 'export DOMAIN_NAME='$DOMAIN_NAME >> /var/opt/meilisearch/env
    echo 'export USE_SSL='$USE_SSL >> /var/opt/meilisearch/env
    echo 'export USE_CERTBOT='$USE_CERTBOT >> /var/opt/meilisearch/env
    echo 'export MEILISEARCH_SERVER_PROVIDER='$MEILISEARCH_SERVER_PROVIDER >> /var/opt/meilisearch/env
    . /var/opt/meilisearch/env

    echo "$BOLD$GREEN     --- OK, now we will set up Meilisearch for you! --- $RESET"

    sudo sh /var/opt/meilisearch/scripts/first-login/001-setup-prod.sh
    exit
}

ask_production_environment() {
    while true; do
        read -p "$(echo $BOLD$BLUE"Do you wish to use Meilisearch in a PRODUCTION environment [y/n]?  "$RESET)" yn
        case $yn in
            [Yy]* ) set_production_env=true; set_master_key=true; break;;
            [Nn]* ) set_production_env=false; break;;
            * ) echo "  Please answer by writing 'y' for yes or 'n' for no.";
        esac
    done
}

ask_master_key_setup() {
    while true; do
        read -p "$(echo $BOLD$BLUE"Do you wish to use a MEILI_MASTER_KEY for your search engine [y/n]?  "$RESET)" yn
        case $yn in
            [Yy]* ) set_master_key=true; break;;
            [Nn]* ) set_master_key=false; break;;
            * ) echo "  Please answer by writing 'y' for yes or 'n' for no.";
        esac
    done
}

generate_master_key() {
    if [ "$MEILISEARCH_MASTER_KEY" != "" ]; then
        echo $BOLD$GREEN'A previous MEILI_MASTER_KEY has been detected. It was set to' $MEILISEARCH_MASTER_KEY$RESET
        while true; do
        read -p "$(echo $BOLD$BLUE"Do you wish to keep using this MEILI_MASTER_KEY for your search engine [y/n]?  "$RESET)" yn
        case $yn in
            [Yy]* ) keep_previous_master_key=true; break;;
            [Nn]* ) keep_previous_master_key=false; break;;
            * ) echo "  Please answer by writing 'y' for yes or 'n' for no.";
        esac
    done
    fi
    if [ "$keep_previous_master_key" = true ]; then
        api_key=$MEILISEARCH_MASTER_KEY
        echo "$BOLD keeping your old MEILI_MASTER_KEY $RESET"
        return
    fi
    while true; do
        read -p "$(echo $BOLD$BLUE"Do you wish to specify your MEILI_MASTER_KEY (otherwise it will be generated) [y/n]? "$RESET)" yn
        case $yn in
            [Yy]* ) read -p 'MEILI_MASTER_KEY: ' api_key; break;;
            [Nn]* ) api_key=$(date +%s | sha256sum | base64 | head -c 32); echo "Your MEILI_MASTER_KEY is $api_key"; echo 'You should keep it somewhere safe.'; break;;
            * ) echo "  Please answer by writing 'y' for yes or 'n' for no.";;
        esac
    done
}

ask_domain_name_setup() {
    while true; do
        read -p "$(echo $BOLD$BLUE"Do you wish to setup a domain name [y/n]? "$RESET)" yn
        case $yn in
            [Yy]* ) ask_domain_name=true; break;;
            [Nn]* ) ask_domain_name=false; break;;
            * ) echo "  Please answer by writing 'y' for yes or 'n' for no.";;
        esac
    done
}

ask_domain_name_input() {
    while true; do
        read -p "$(echo $BOLD$BLUE"What is your domain name? "$RESET)" domainname
        case $domainname in
            "" ) echo '  Please enter a valid domain name';;
            * ) break;;
        esac
    done
}

ask_ssl_configure() {
    while true; do
        read -p "$(echo $BOLD$BLUE"Do you wish to setup ssl with certbot (free and automated HTTPS) [y/n]? "$RESET)" yn
        case $yn in
            [Yy]* ) want_ssl_certbot=true; break;;
            [Nn]* ) want_ssl_certbot=false; break;;
            * ) echo "  Please answer by writing 'y' for yes or 'n' for no.";
        esac
    done
}

ask_has_own_ssl() {
    while true; do
        read -p "$(echo $BOLD$BLUE"Do you wish to provide your own SSL certificate [y/n]? "$RESET)" yn
        case $yn in
            [Yy]* ) has_own_ssl=true; break;;
            [Nn]* ) has_own_ssl=false; break;;
            * ) echo "  Please answer by writing 'y' for yes or 'n' for no.";
        esac
    done
}

# This let's us avoid asking user for input and set production environment from Mmetadata

if [ "$MEILI_SKIP_USER_INPUT" = 'true' ]; then
    . /var/opt/meilisearch/env
    sh /var/opt/meilisearch/scripts/first-login/001-setup-prod.sh
fi

# Ask user if he wants to setup a master key for Meilisearch

ask_production_environment

if [ $set_production_env = false ]; then
    MEILISEARCH_ENVIRONMENT='development'
    echo '  Meilisearch will be run in a DEVELOPMENT environment'
    ask_master_key_setup
else
    MEILISEARCH_ENVIRONMENT='production'
    echo '  Meilisearch will be run in a PRODUCTION environment'
    echo '  MEILI_MASTER_KEY must be set for PRODUCTION'
    echo '  Front-end integrated dashboard will be disabled for PRODUCTION'
fi

if [ $set_master_key = true ]; then
    generate_master_key
    USE_API_KEY='true'
    MEILISEARCH_MASTER_KEY=$api_key
else
    USE_API_KEY='false'
    MEILISEARCH_MASTER_KEY=""
fi

# Ask user if he wants to setup a domain name for Meilisearch

ask_domain_name_setup

if [ $ask_domain_name != true ]; then
    DOMAIN_NAME=''
    USE_SSL='false'
    USE_CERTBOT='false'
    exit_with_message
fi

ask_domain_name_input

DOMAIN_NAME=$domainname

# Ask user if he wants to setup an SSL configuration for Meilisearch
# [certbot or own SSL]

ask_ssl_configure

if [ $want_ssl_certbot = true ]; then
    USE_SSL='true'
    USE_CERTBOT='true'
else
    USE_CERTBOT='false'
    ask_has_own_ssl
fi

if [ $want_ssl_certbot = false ] && [ $has_own_ssl = true ]; then
    USE_SSL='true'
    USE_CERTBOT='false'
fi

exit_with_message

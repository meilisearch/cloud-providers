<p align="center">
  <img src="https://github.com/meilisearch/integration-guides/blob/main/assets/logos/logo.svg" alt="Meilisearch Cloud Providers" width="200" height="200" />
</p>

<h1 align="center">Meilisearch Cloud Providers</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/meilisearch">Meilisearch</a> |
  <a href="https://docs.meilisearch.com">Documentation</a> |
  <a href="https://discord.meilisearch.com">Discord</a> |
  <a href="https://roadmap.meilisearch.com/tabs/1-under-consideration">Roadmap</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://docs.meilisearch.com/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://github.com/meilisearch/cloud-providers/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-informational" alt="License"></a>
</p>

<p align="center">☁ Meilisearch tools for the Cloud ☁</p>

**Meilisearch Cloud Providers** is a set of tools and scripts allowing to build Meilisearch images for multiple platforms made with [Packer](https://www.packer.io/).

**Meilisearch** is an open-source search engine. [Discover what Meilisearch is!](https://github.com/meilisearch/meilisearch)

## Table of Contents <!-- omit in toc -->

- [🎁 Content of this repository](#-content-of-this-repository)
- [📖 Providers available](#-providers-available)
- [📖 Documentation](#-documentation)
- [🔧 Prerequisites](#-prerequisites)
- [🔑 Set your credentials](#-set-your-credentials)
- [🚀 Getting Started](#-getting-started)

## 🎁 Content of this repository

:warning: This repository is in WIP.

These Packer build configurations are used primarily by the Meilisearch integration team, aiming to provide our users simple ways to deploy and configure Meilisearch in the cloud by creating ready-made images of Meilisearch. As our heart resides in the open-source community, we maintain several of these tools as open-source repositories.

## ☁ Providers available

| Cloud Provider |
|----------|
| AWS |
| DigitalOcean |
| GCP |

## 📖 Documentation

See our [Documentation](https://docs.meilisearch.com/learn/tutorials/getting_started.html) or our [API References](https://docs.meilisearch.com/reference/api/).

## 🔧 Prerequisites

You need the following to run the template:
1. The [Packer CLI v1.8.6+](https://developer.hashicorp.com/packer/downloads) installed locally
2. Obtain your [AWS access keys](https://docs.aws.amazon.com/keyspaces/latest/devguide/access.credentials.html)
3. Obtain your [DigitalOcean API Token](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)
4. Obtain your [GCP credentials](https://cloud.google.com/docs/authentication/application-default-credentials)

## 🔑 Set your credentials

- Aws
``` bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
```
- DigitalOcean
```bash
export DIGITALOCEAN_API_TOKEN="XxXxxxxXXxxXXxxXXxxxXXXxXxXxXX"
```
- GCP
```bash
export GOOGLE_APPLICATION_CREDENTIALS="path_to_your_creadential_file.json"
```

## 🚀 Getting Started

### Initialize your Packer configuration
Download and install packer plugins

``` bash
packer init .
```

### Build all the images

⚠ Please note that this command will create all new Meilisearch images on all platforms of the specified version.

``` bash
packer build meilisearch.pkr.hcl
```

### Build an image just for one provider

⚠ Please note that this command will create new Meilisearch image on the dedicated platforms of the specified version.

``` bash
packer build -only 'amazon-ebs.*' .
```

``` bash
packer build -only 'digitalocean.*' .
```

``` bash
packer build -only 'googlecompute.*' .
```

## 🚀 How to deploy Meilisearch 

If you want to learn how to deploy a Meilisearch instance on DigitalOcean visit the dedicated page of our documentation:
- [AWS](https://www.meilisearch.com/docs/learn/cookbooks/aws)
- [DigitalOcean](https://www.meilisearch.com/docs/learn/cookbooks/digitalocean)
- [GCP](https://www.meilisearch.com/docs/learn/cookbooks/gcp)


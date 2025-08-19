<p align="center">
  <img src="https://github.com/meilisearch/integration-guides/blob/main/assets/logos/logo.svg" alt="Meilisearch Cloud Providers" width="200" height="200" />
</p>

<h1 align="center">Meilisearch Cloud Providers</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/meilisearch">Meilisearch</a> |
  <a href="https://www.meilisearch.com/cloud?utm_campaign=oss&utm_source=github&utm_medium=cloud-providers">Meilisearch Cloud</a> |
  <a href="https://www.meilisearch.com/docs">Documentation</a> |
  <a href="https://discord.meilisearch.com">Discord</a> |
  <a href="https://roadmap.meilisearch.com/tabs/1-under-consideration">Roadmap</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://www.meilisearch.com/docs/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://github.com/meilisearch/cloud-providers/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-informational" alt="License"></a>
  <a href="https://ms-bors.herokuapp.com/repositories/51"><img src="https://bors.tech/images/badge_small.svg" alt="Bors enabled"></a>
</p>
<p align="center">⚠️ Project Archived – Official Images Deprecated </p>
<p align="center">☁ Meilisearch tools for the Cloud ☁</p>

> **We are no longer maintaining or publishing the official Meilisearch one-click deploy images on AWS Marketplace and DigitalOcean Marketplace**.
>
> If you are currently using these images, to keep receiving the latest features and updates:
>
> - You can either deploy Meilisearch yourself (Docker, binary, or Helm chart)
> - Or use [Meilisearch Cloud](https://cloud.meilisearch.com/login), which offers flexible pricing (resource-based or usage-based). With Meilisearch Cloud, deployment and scaling are fully managed, and updates are applied automatically — making it the easiest way to always stay up to date.
>
> :arrow_right: For larger companies or teams with specific needs (including migration support), you can book a meeting with our sales team at sales@meilisearch.com.
> 
> :bulb: If you are running Meilisearch on your own infrastructure but need support for specific features, we also offer commercial licenses. Contact us to learn more at sales@meilisearch.com.
>
> :envelope_with_arrow: If you wish to maintain an official image of Meilisearch on AWS or DigitalOcean, please reach out at bonjour@meilisearch.com — we’ll be happy to accommodate.
This repository is now archived and will no longer receive updates.

**Meilisearch Cloud Providers** is a set of tools and scripts allowing to build Meilisearch images for multiple platforms made with [Packer](https://www.packer.io/).

**Meilisearch** is an open-source search engine. [Discover what Meilisearch is!](https://github.com/meilisearch/meilisearch)

## Table of Contents <!-- omit in toc -->

- [🎁 Content of this repository](#-content-of-this-repository)
- [⚡ Supercharge your Meilisearch experience](#-supercharge-your-meilisearch-experience)
- [📖 Providers available](#-providers-available)
- [📖 Documentation](#-documentation)
- [🔧 Prerequisites](#-prerequisites)
- [🔑 Set your credentials](#-set-your-credentials)
- [🚀 Getting Started](#-getting-started)


## ⚡ Supercharge your Meilisearch experience

Say goodbye to server deployment and manual updates with [Meilisearch Cloud](https://www.meilisearch.com/cloud?utm_campaign=oss&utm_source=github&utm_medium=cloud-providers). Get started with a 14-day free trial! No credit card required.

## 🎁 Content of this repository

These Packer build configurations are used primarily by the Meilisearch integration team, aiming to provide our users simple ways to deploy and configure Meilisearch in the cloud by creating ready-made images of Meilisearch. As our heart resides in the open-source community, we maintain several of these tools as open-source repositories.

## ☁ Providers available

| Cloud Provider |
|----------|
| AWS |
| DigitalOcean |
| GCP - ⚠️ Deprecated, no more image published anymore |

## 📖 Documentation

See our [Documentation](https://www.meilisearch.com/docs/learn/getting_started/installation) or our [API References](https://www.meilisearch.com/docs/reference/api/overview).

## 🔧 Prerequisites

You need the following to run the template:
1. The [Packer CLI v1.8.6+](https://developer.hashicorp.com/packer/downloads) installed locally
2. Obtain your [AWS access keys](https://docs.aws.amazon.com/keyspaces/latest/devguide/access.credentials.html)
3. Obtain your [DigitalOcean API Token](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)

## 🔑 Set your credentials

- Aws
``` bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
```
- DigitalOcean
```bash
export DIGITALOCEAN_TOKEN="XxXxxxxXXxxXXxxXXxxxXXXxXxXxXX"
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

## 🚀 How to deploy Meilisearch

If you want to learn how to deploy a Meilisearch instance on DigitalOcean visit the dedicated page of our documentation:
- [AWS](https://www.meilisearch.com/docs/guides/deployment/aws)
- [DigitalOcean](https://www.meilisearch.com/docs/guides/deployment/digitalocean)


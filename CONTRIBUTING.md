# Contributing <!-- omit in TOC -->

First of all, thank you for contributing to Meilisearch! This document aims to provide everything you need to know to contribute to this Meilisearch integration.

- [Assumptions](#assumptions)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Git Guidelines](#git-guidelines)
- [Release Process (for the internal team only)](#release-process-for-internal-team-only)

## Assumptions

1. **You're familiar with [GitHub](https://github.com) and the [Pull Request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)(PR) workflow.**
2. **You've read the Meilisearch [documentation](https://www.meilisearch.com/docs) and the [README](/README.md).**
3. **You know about the [Meilisearch community](https://discord.com/invite/meilisearch). Please use this for help.**

## How to Contribute

1. Make sure that the contribution you want to make is explained or detailed in a GitHub issue! Find an [existing issue](https://github.com/meilisearch/cloud-providers/issues/) or [open a new one](https://github.com/meilisearch/cloud-providers/issues/new).
2. Once done, [fork the cloud-providers repository](https://help.github.com/en/github/getting-started-with-github/fork-a-repo) in your own GitHub account. Ask a maintainer if you want your issue to be checked before making a PR.
3. [Create a new Git branch](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-and-deleting-branches-within-your-repository).
4. Make the changes on your branch.
5. [Submit the branch as a PR](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork) pointing to the `main` branch of the main cloud-providers repository. A maintainer should comment and/or review your Pull Request within a few days. Although depending on the circumstances, it may take longer.<br>
 We do not enforce a naming convention for the PRs, but **please use something descriptive of your changes**, keeping in mind that the title of your PR will be automatically added to the following [release changelog](https://github.com/meilisearch/cloud-providers/releases/).

You can check out the more extended, complete guideline documentation [here](https://github.com/meilisearch/.github/blob/main/Hacktoberfest_2022_contributors_guidelines.md).

## Development Workflow

### Setup <!-- omit in toc -->

1. Install the [Packer CLI](https://developer.hashicorp.com/packer/downloads)
2. Set up all your needed credentials
- AWS:
Obtain your [AWS access keys](https://docs.aws.amazon.com/keyspaces/latest/devguide/access.credentials.html) and set it in your environment:
  ``` bash
    export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
  ```
- DigitalOcean:
Before running any script, make sure to [obtain a DigitalOcean API Token](https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/) and set it in your environment:
  ```bash
  export DIGITALOCEAN_ACCESS_TOKEN="XxXxxxxXXxxXXxxXXxxxXXXxXxXxXX"
  ```
- GCP:
Obtain your [GCP credentials](https://cloud.google.com/docs/authentication/getting-started) and set it in your environment:
  ```bash
  export GOOGLE_APPLICATION_CREDENTIALS="path_to_your_creadential_file.json"
  ```
3. Download and install Packer plugins
    ``` bash
    packer init .
    ```

### Tests and Linter <!-- omit in toc -->

Each PR should pass the tests and the linter to be accepted.

Use this command to format HCL2 configuration file:
``` bash
packer fmt .
```

Use this command to validate the syntax and configuration of the template:
``` bash
packer validate .
```

### Build the images <!-- omit in toc -->

⚠ Please be aware that this command will create all new Meilisearch images on all platforms.

This command will execute the template and build all images in parallel:
``` bash
packer build meilisearch.pkr.hcl
```

You can build one or more images by specifying their name, take the first parameter given to `source` block and add it the following wildcard regex: `.*`.
Example:
``` bash
packer build -only 'amazon-ebs.*' .
```

### Add a new provider

There are multiple providers available for Packer, you can check the [External Plugins Documentation](https://developer.hashicorp.com/packer/plugins)

To add a provider correctly to the list of existing providers, proceed as follows:
1. Add your code to the primary meilisearch.pkr.hcl file as expected.
  - Incorporate specific variables into the `variables` block at the beginning of the file if necessary.
  - Introduce the plugin of your new provider into the `packer` block.:
    ```
    packer {
    required_plugins {
      ...
      mynewprovider = {
          ...
        }
      }
    }
    ```
  - Lastly, you will need to create a new `source` block for your provider. To accomplish this, please consult the specific documentation for each plugin as your guide.
    ```
    source "mynewprovider" "debian" {
      ...
    }
    ```
2. Add the provider name to the [README](README.md#-providers-available).
3. Add a manual trigger for your new provider to the CI by adding it to the list of suppliers in the `option` block of [manual_publish.yml](/manual_publish.yml).

## Git Guidelines

### Git Branches <!-- omit in TOC -->

All changes must be made in a branch and submitted as PR.
We do not enforce any branch naming style, but please use something descriptive of your changes.

### Git Commits <!-- omit in TOC -->

As minimal requirements, your commit message should:
- Be capitalized
- Not finish by a dot or any other punctuation character (!,?)
- Start with a verb so that we can read your commit message this way: "This commit will ...", where "..." is the commit message.
  e.g.: "Fix the home page button" or "Add more tests for create_index method"

We don't follow any other convention, but if you want to use one, we recommend [this one](https://chris.beams.io/posts/git-commit/).

### GitHub Pull Requests <!-- omit in TOC -->

Some notes on GitHub PRs:
- [Convert your PR as a draft](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/changing-the-stage-of-a-pull-request) if your changes are a work in progress: no one will review it until you pass your PR as ready for review.<br>
  The draft PR can be very useful if you want to show that you are working on something and make your work visible.
- The branch related to the PR must be **up-to-date with `main`** before merging. If it's not, you have to rebase your branch. Check out this [quick tutorial](https://gist.github.com/curquiza/5f7ce615f85331f083cd467fc4e19398) to successfully apply the rebase from a forked repository.
- All PRs must be reviewed and approved by at least one maintainer.
- The PR title should be accurate and descriptive of the changes.

## Release Process (for the internal team only)

Meilisearch tools follow the [Semantic Versioning Convention](https://semver.org/).

The release tags of this package follow exactly the Meilisearch versions.<br>
For example, the `v1.1.1` tag in this repository corresponds to the image running Meilisearch `v1.1.1`.

**Please follow the steps in the next sections carefully before any release.**

### Automated Publishing <!-- omit in TOC -->

Building and deploying all new Meilisearch images on all platforms is done automatically by a github action when a new tag is pushed to main.

### Release, Build and Publish <!-- omit in TOC -->

⚠️ The image should never be published with a `RC` version of Meilisearch.

1. In the file [`meilisearch.pkr.hcl`](meilisearch.pkr.hcl), update the value of the `default` variable in the block `meilisearch_version` with the new version of Meilisearch you want to release, in the format: `vX.X.X`.
2. Commit your changes to a new branch.
3. Open a PR from the branch where changes were done and merge it.
4. Create a git tag on the last `main` commit:

```bash
git checkout main
git pull origin main
git tag vX.X.X
git push origin vX.X.X
```
This will start building and publishing all images on all platforms.

### Publish each image manually <!-- omit in TOC -->

In case a publication did not go well, you can manually launch each building image separately in the GitHub interface.
- Click on the Action tab.
- Choose the "Publish Manually" action on the left sidebar.
- On the right side of the screen, select the `Use workflow from` panel.
- On `Use workflow from` keep `Branch: main`.
- On `Choose the provider you want to publish` select the provider you want to re-deploy.

### Publish the DigitalOcean image <!-- omit in TOC -->

In the [DigitalOcean Vendor Portal](https://marketplace.digitalocean.com/vendorportal), click on the title of the `Meilisearch` image. A form will open for a new image submission. Update the information regarding the latest version in the document:

- Update the `App version` (with the version number, without the starting v, so `vX.X.X` becomes `X.X.X`).
- In the `System image` field, click `Select system image` and select the image you tested from the list (`Meilisearch-v.X.X.X-Debian-X`).
- In the `Software Included` field, update the Meilisearch version.
- Check the `Application summary`, `Application Description`, and `Getting started instructions` fields for any conflicting information that should be updated about Meilisearch usage or installation.
- In the `Reason for update` field, write "Bump Meilisearch to vX.X.X".
- Verify the form, and hit on `Submit`.

⚠️ When the image is submitted to the Marketplace, Meilisearch will immediately lose its ownership. The submitted image won't appear in the organization dashboard anymore, and no further modification can be done.

This will start the DigitalOcean review process. This can take a few days, and the result will be notified via email to the DigitalOcean admin account. If the image is accepted, it will be automatically published on the Marketplace. If it is rejected, an email explaining the problems will be sent to administrators.

### Create the Virtual disk (VMDK) for GCP <!-- omit in TOC -->

In the [GCP website](https://console.cloud.google.com/)

- Navigate to "Compute Engine" -> "Images"
- Click on the image you just create `meilisearch-X-X-X-debian-X`
- Click on `EXPORT`
- On: "Export format" choose `VMDK`
- On: "Path*" click on `BROWSE` and select `meilisearch-image`
- Validate it by clicking on the SELECT button at the bottom
- Finally click on the EXPORT button at the buttom

## Cleaning old images (Optional)

You may want to clean up the old images.

### Digital Ocean

For Digital Ocean, each new image submitted deletes the old one.
However if you have made a copy so that it is available from the dashboard:
- Go to Manage
- Click on image. You will then have access to the entire list of images
- Click on more on the right and choose delete

### GCP

In this case there is no way to do it yet on GCP
- Go to cloud-storage
- Click on meilisearch-image. You will have access to a list of all vdmk images
- Select the image you wish to delete
- Click delete

### AWS

- Download this [obsolete repository](https://github.com/meilisearch/meilisearch-aws)
- After making sure you have installed everything correctly(https://github.com/meilisearch/meilisearch-aws/blob/main/CONTRIBUTING.md#development-workflow)
- Follow [this guide](https://github.com/meilisearch/meilisearch-aws/blob/main/CONTRIBUTING.md#clean-old-aws-ami-images-)

Thank you again for reading this through, we can not wait to begin to work with you if you make your way through this contributing guide ❤️
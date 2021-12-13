Steps for building images

[Packer](https://www.packer.io) is used to automate and build virtual machine images from scratch. Much of the artifacts used in the sub directory come from the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository in GitHub. This repository is maintained by the GitHub and Azure DevOps product team to automate the agent images that are used. 

## Bootstrapping steps

## Image Building

Two ways much be supported in image building. Interactive local machine support to support the engineer making updates to changes in the build, and an approved pipeline that will build the image to be used in production.

Packer uses several [authentication options](https://www.packer.io/docs/builders/azure/arm#authentication-options) for Packer to build iamges. The two that are used are:

1. [Interactive user authentication](https://www.packer.io/docs/builders/azure/arm#interactive-user-authentication) used for engineer development support
2. [Managed Identity](https://www.packer.io/docs/builders/azure/arm#managed-identity) for use in pipelines

> It's also recommended to run Packer as a managed identity to test RBAC before running in a pipeline.

## REcommendations
- CI Builds

Setup a seperate CI build for each image. Schedule these builds at a fairly regular interval such as daily or weekly. This makes sure
that each image that is built is still operating. These images have a lot of dependencies that could break and the only true way to 
tell if they are still working is to run fully run them. You can optionally setup this CI build up to simply run this and discard any
output.

- Packer Templates

Follow the [Goldilocks principle](https://en.wikipedia.org/wiki/Goldilocks_principle) while creating templates. We don't want too many defined tempaltes as that can cause too much mangement overhead as well as 
incure cost. But we also don't want a single Linux image with too many dependencies. Take a measure approach. 


## Packer Templates

There are several Packer templates that are built by the product team. These should be left along as a reference to help
diagnose any issues over time. Templates names with the prefix "test-" are variations of these templates that are customized
with different settings, but are essentially the same and are used as tests.

The basic workflow to get updates from the product team as well as diagnose problems are:

1. Update the list of templates from the product team
2. Compare the list of templates with all the "test-" templates and review changes
3. Update "test-" templates
4. Run CI build on all baseline templates
5. Optionally turn on verbose logging in CI to help diagnose issues

## Strategy

This repo loosely aligns the product teams appraoch to image building. If the product team switches strategy, then this repo 
should follow that strategy. It's anticipated that the user of Packer will change in the future due to current use of the 
older JSON templating. A deprecation is currently in the logs and is recognized. The product team may switch to using
Azure Image Builder or move to the new HCL templates in the future. 
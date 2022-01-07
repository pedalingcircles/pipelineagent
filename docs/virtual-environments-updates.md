# Updating from [actions/virtual-environments](https://github.com/actions/virtual-environments)

This repository leverages a lot of source files from the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository on [GitHub](https://github.com). That repository is used by the [ADO](https://azure.microsoft.com/en-us/services/devops) and [GitHub](https://github.com) product teams to automate both the virtual environments for [GitHub Actions](https://github.com/features/actions) as well the VM images for the [Microsoft-hosted agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=azure-devops&tabs=browser#install). This repository leverages the baseline images for both Linux and Windows (macOS is not yet supported in this repo yet) because most of the automation is useful, including Packer templates, installers, test cases, and configuration.

The [vm-images/images](vm-images/images) directory in this repository is associated with the [images](https://github.com/actions/virtual-environments/tree/main/images) directory in the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository.

Comparing large amounts of files between two seperate repos is difficult and error prone. Several methods have been tried to make this as easy as possible, however there is no [silver bullet](https://en.wikipedia.org/wiki/Silver_bullet), so care must be taken to make sure all changes are valid. The basic strategy is to compare folders and create a convention to easily identity files that are not in the this repository that are in the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository and vice versa. Also easily identity files that augment the capability that are specific to this repository through convention. The convention is to prefix all files (scripts and config files) with an underscore (`_`). For example, there is a script named `preimagedata.sh` that is in both repositories. We leave this file alone. But we want to change this file and only reference it in this repository. So we change this file to `_preimagedata.sh` and make changes. This allows manage change a little easier and also compare if there are any new updates to `preimagedata.sh`.

Guidelines:

- Make small batch changes
- Don't wait too long between updates from the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository
- Image builds on all supported images should be run at a regular cadence either daily or weekly

> Running image builds on a regular cadence is important because these builds rely on many external installer scripts that are external to the internal dependency management tool. If we are running a daily and an image breaks, then the team gets notified and can fix the issue quickly without letting too much time pass.

<!-- -->
> When an image breaks, it's often the case that this is something that is already identified by the product team. Visiting their [Issues](https://github.com/actions/virtual-environments/issues) page will likely have this already recorded and you can simply wait for the fix and take an update to verify.

## Steps to update

### 1. Create a [topic branch](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows#_topic_branch)

```console
user@machine:~/pipelineagent$ git checkout -b new-topic-branch
```

### 2. Create Git subtree

```console
user@machine:~/pipelineagent$ git subtree add --prefix .virtual-environments https://github.com/actions/virtual-environments.git main --squash
```

### 3. Compare `.virtual-environments/images` (subtree) directory to the `vm-images/images` directory

Use a [file comparison](https://en.wikipedia.org/wiki/File_comparison) tool to compare artifacts between the two directories to find updates and make changes

Add new files and directories that exist in `.virtual-environments/images` and not `vm-images/images`. Then look for files and directories that no longer exist in `.virtual-environments/images` and still exist in `vm-images/images` and remove them (with the exception of files with an underscore prefix or any custom Packer templates). Then review changed files which in most cases you can simply overwrite with updates.

Review all changes and determine if any updates need to be made to Packer templates and make those changes.

> Compare changes between OS folders one at a time for easier management. Compare corresponding `linux` directories and then compare the corresponding `win` directories.

<!-- -->
> You may run into files that look the same but are showing up as a difference or delta. In this case, verify the [line endings](https://en.wikipedia.org/wiki/Newline) `LF` and `CRLF`. They could be different.

### 4. Run image builds from local machine to test and fix on all updated images

Run a Packer build from you local machine by running the [New-PackerImage.ps1](/scripts/New-PackerImage.ps1) script. You need an Azure subscription with the infrastructure already setup to run. This script assumes that a resource group with a virtual network is protecting where the working image will be landed. Since this is coming from a local machine you need to have networking that will support this.

> A local machine can be sitting inside or outside of Azure, if inside and you are using remote desktop then it's likely that access is already given.

### 5. Delete `.virtual-environments` directory

```console
user@machine:~/pipelineagent$ git rm .virtual-environments -r
```

Deleting this folder will create many changes due to the deletion of files. Go ahead and commit these changes in the [topic branch](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows#_topic_branch). Later when merging the [topic branch](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows#_topic_branch) into the trunk, make sure to perform a  **squash merge** so the changes and history are not polluted with unwanted commits from the subtree deletion.

### 6. Create a pull request to verify image builds and changes work

The pull request ideally should run all Packer image builds to make sure they work. This will take at least 6 hours if all goes well and if they are all run concurrently.

### 7. Make sure to **squash merge** changes to avoid unwanted history from the subtree (mainly deletes)

Again, it's important to **squash merge** when completing the pull request. It's important to avoid polluted history mainly due to pulling in the subtree. Because of this, it's also important to do small batch chnages in the topic branch and do a complete write up for the pull request.

### 8. Monitor pull reqest as it make take over a day to complete depending on changes

### 9.  After pull request completes, monitor image builds success on trunk and verify they have been built

# Updating from [actions/virtual-environments](https://github.com/actions/virtual-environments)

This repository leverages a lot of source from the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository on [GitHub](https://github.com). That repository is used by the ADO and GitHub product teams to automate both the virtual environments for GitHub Actions as well the VM images for the Microsoft-hosted agents. This repository leverages the baseline images for both Linux and Windows (macOS not yet supported) because most of the automation is useful including Packer templates, installers, test cases and configuration.

The [vm-images/images](vm-images/images) directory in this repository is associated with the [images](https://github.com/actions/virtual-environments/tree/main/images) directory in the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository.

Comparing large amounts of file between two seperate repos is difficult and error prone. Several methods have been tried to make this as easy as possible, however there is no [silver bullet](https://en.wikipedia.org/wiki/Silver_bullet) so care must be taken to make sure all changes are valid. The basic strategy is to compare folders and create a convention to easily identity files that are not in the source repo. That convention is to prefix all files (scripts adn config files) with an underscore `_`. For example. There is a scripts name `preimagedata.sh` that is in the source repo. We leave this file along. But we want to change this file and only reference it in our source repo, this repo. So we change this file to `_preimagedata.sh` and make changes. This allows manage change a little easier.

Guidelines:

- Make small batch changes if possible
- Don't wait too long between  updates from the [actions/virtual-environments](https://github.com/actions/virtual-environments) repository
- Image builds on all supported images should be run at a regular cadence either daily or weekly

> See [tips](./docs/tips.md#git-subtree) to get the common Git CLI commands

## Steps to update

1. Create topic branch

```console
user@machine:~/pipelineagent$ git checkout -b new-topic-branch
```

2. Create Git subtree

```console
user@machine:~/pipelineagent$ git subtree add --prefix .virtual-environments https://github.com/actions/virtual-environments.git main --squash
```

3. Compare `.virtual-environments/images` (subtree) directory to `vm-images/images` directory

Add new files and directories that exist in `.virtual-environments/images` and not `vm-images/images`. Then look for files and directories that no longer exist in `.virtual-environments/images` and still exist in `vm-images/images` and remove them (with the exception of files with an underscore prefix). Then review changed files which in most cases you can simply overwrite with updates.

Review all changes and determin if any updates need to be make to Packer templates and make those changes.







4. Use a [file comparison](https://en.wikipedia.org/wiki/File_comparison) tool to compare artifacts between the two directories to find updates and make changes
5. Run image builds from local machine to test fix on all updated images
6. Delete `.virtual-environments` directory
7. Open Pull Request to verify image builds and changes work
8. Make sure to **squash** changes to avoid unwanted history from the subtree (mainly deletes)
9.  Monitory pull reqest as it make take over a day to complete depending on changes
10. After pull request completes, monitor image builds success on trunk and verify they have been built

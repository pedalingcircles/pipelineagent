
az sig image-version create `
    -g msft-aware-imagegen-agent-ci `
    --gallery-name contosoimagegallery `
    --gallery-image-definition AgentBuildv1 `
    --gallery-image-version 1.0.1 `
    --managed-image /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/msft-aware-imagegen-agent-ci/providers/Microsoft.Compute/images/packer-Ubuntu2004-20210302.2
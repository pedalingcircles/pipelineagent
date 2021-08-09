
az sig image-version create `
    -g msft-aware-imagegen-agent-ci `
    --gallery-name contosoimagegallery `
    --gallery-image-definition AgentBuildv1 `
    --gallery-image-version 1.0.1 `
    --managed-image /subscriptions/cbadc96b-2923-4459-bb2d-b237af7f84d6/resourceGroups/msft-aware-imagegen-agent-ci/providers/Microsoft.Compute/images/packer-Ubuntu2004-20210302.2
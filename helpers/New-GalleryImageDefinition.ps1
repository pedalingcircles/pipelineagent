$resourceGroup = "msft-aware-imagegen-agent-ci"
$gallery = "contosoimagegallery"

$imageDef = "AgentBuildv1"

az sig image-definition create `
   --resource-group $resourceGroup `
   --gallery-name $gallery `
   --gallery-image-definition $imageDef `
   --publisher Contoso `
   --offer TheBest `
   --sku Consumption `
   --os-type Linux `
   --os-state Generalized
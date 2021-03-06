param name string
param location string
param tags object = {}
param description string = 'Shared Image Gallery used to store virtual machine images used for creating self-hosted Azure DevOps Agents.'

resource sharedImageGallery 'Microsoft.Compute/galleries@2020-09-30' = {
  name: name
  location: location
  tags: tags
  properties: {
    description: description
  }
}

output id string = sharedImageGallery.id

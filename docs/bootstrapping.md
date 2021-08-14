# Bootstrapping Steps

This repository supports only building new images and provisioning from self-hosted images that already exist. However, if this is not in place
there are steps you can take to stand up at least one self-hosted agent. There are two fundamental reasons why this repo doesn't support hosted agents:

1. Security and networking that use hosted agents aren't practical due to opening up too many holes in the network as as well maintaining and managing updates
2. There are hard timeouts on hosted agents which prevent certain images to succeed. Namely Windows based images since they take a significant amout of time to create in comparison to Linxu images.
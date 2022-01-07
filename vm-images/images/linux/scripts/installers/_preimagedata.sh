#!/bin/bash -e
#
# Creates an image data file based on agent meta data.
#
# The meta data in this file will show up in the "Initialize job" 
# step during a job run.  The specific information to capture is 
# the "Operating System" group and  the "Virtual Environment" group.
#
# This script is based on the preimagedata.sh script which
# comes from the actions/virtual-environments repository. 
# This scripts replaces that script when building 
# custom Packer images.

imagedata_file=$IMAGEDATA_FILE
image_version=$IMAGE_VERSION
os_name=$(lsb_release -ds | sed "s/ /\\\n/g")
image_label=$IMAGE_LABEL
software_url=$SOFTWARE_URL
release_url=$RELEASE_URL

cat <<EOF > $imagedata_file
[
  {
    "group": "Operating System",
    "detail": "${os_name}"
  },
  {
    "group": "Virtual Environment",
    "detail": "Environment: ${image_label}\nVersion: ${image_version}\nIncluded Software: ${software_url}\nImage Release: ${release_url}"
  }
]
EOF

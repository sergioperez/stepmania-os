## Building

This project can be build locally with the script `build.sh`.

The main requirements are `podman`, and a tool to run VMs to test the output.

## Pipelines 

# Push to main

Builds and pushes an image with the tags `latest` and `release-gameversion-digest`

# Push to beta

Builds and pushes an image with the tags `beta` and `beta-gameversion-digest`

# Create PR

Builds and pushes an image with the tag pr-prnumber-digest

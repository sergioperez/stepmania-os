#!/usr/bin/bash
IMAGE="itgdev.local:5000/test:latest"
mkdir tmp

## Cleanup
rm -rf test.tar.gz
sudo rm -rf output/* 
sudo podman rmi ${IMAGE}

set -e
podman build . -t ${IMAGE}
#podman push ${IMAGE}

podman save ${IMAGE} -o test.tar.gz
sudo podman load --input test.tar.gz

#sudo podman pull itgdev.local:5000/test:latest
types="iso qcow2 raw" # qcow2, iso, raw
for type in ${types}
do
	sudo podman run --rm -it --privileged --pull=newer \
		--security-opt label=type:unconfined_t \
		-v ./config.toml:/config.toml:ro -v ./output:/output \
		-v /var/lib/containers/storage:/var/lib/containers/storage \
		quay.io/centos-bootc/bootc-image-builder:latest \
			--type ${type} --rootfs btrfs --use-librepo=True ${IMAGE}
done

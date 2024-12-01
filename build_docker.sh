#!/bin/bash
set -e

docker build --build-arg USER_ID=$(id -u) --build-arg USER_NAME=$(whoami) -t nxp-ubuntu docker/ubuntu
if [ $? -eq 0 ]; then
	echo "Build docker nxp-ubuntu successfully!"
else
	echo "Failed to build nxp-ubuntu."
fi

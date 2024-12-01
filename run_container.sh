#!/bin/bash
set -e

log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_info() {
	log "[INFO] $1"
}

log_error() {
	log "[ERROR] $1"
}

check_ret() {
	if [ $1 -eq 0 ]; then
		log_info "$2 done!"
	else 
		log_error "Failed on $2!"
	fi
}

log_info "Starting to run docker container"
docker run \
	--cap-add NET_ADMIN \
	--hostname buildserver \
	-it \
	-v `pwd`/../flexbuild_lsdk2108:/home/$(whoami)/layerscape \
	nxp-ubuntu

check_ret $? "Docker container run"		

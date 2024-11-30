#!/bin/bash

# A launcher for the ioc-adsimdetector-demo IOC
#
# This also serves as an example of serving PVAccess from inside a container
# network using the PVA Gateway.
#
this_dir=$(dirname $0)

# prefer podman but use docker if USE_DOCKER is set
if podman version &> /dev/null && [[ -z $USE_DOCKER ]]
    then docker=podman; UIDGID=0:0
    else docker=docker; UIDGID=$(id -u):$(id -g)
fi
echo "Using $docker as container runtime"

args="--rm -it"
ca="-p 127.0.0.1:5064:5064/udp -p 127.0.0.1:5064-5065:5064-5065"
pva="-p 127.0.0.1:5076:5076/udp -p 127.0.0.1:5075:5075"
vols="-v /tmp:/tmp"
image="ghcr.io/epics-containers/pva-demo-developer:2024.11.2"

set -x
$docker run $args $ca $pva $vols $image

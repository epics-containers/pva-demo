#!/bin/bash

# A launcher for the ioc-adsimdetector-demo IOC
#
# This also serves as an example of serving PVAccess from inside a container
# network using the PVA Gateway.
#
this_dir=$(dirname $0)

# prefer docker but use podman if USE_PODMAN is set
if docker version &> /dev/null && [[ -z $USE_PODMAN ]]
    then docker=docker
    else docker=podman
fi

args="--rm -it"
ca="-p 127.0.0.1:5064:5064/udp -p 127.0.0.1:5064-5065:5064-5065"
pva="-p 127.0.0.1:5076:5076/udp -p 127.0.0.1:5075:5075"
vols="-v /tmp:/tmp"
image="ghcr.io/epics-containers/pvagw-demo:2024.11.1"

set -x
$docker run $args $ca $pva $vols $image

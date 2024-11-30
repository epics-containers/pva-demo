#!/bin/bash

# RUN this script INSIDE the container to start the PVA Gateway
#
# It allows us to serve PVAccess outside of the container using
# using the nameservers facility of pvxs clients.
#
# Use of UDP broadcasts for accessing PVA inside of a container network
# fails because it cannot pass through a NAT router.
#
this_dir=$(dirname $0)

# determine the broadcast address of the container network
broadcast=$(ifconfig | sed -rn 's/^.*broadcast (.*)$/\1/p')
# add the broadcast address to the pva gateway config
cat $this_dir/pvagw.config | \
  sed -e "s/replace_with_broadcast_address/$broadcast/" >/tmp/pvagw.config

# start the gateway
pvagw /tmp/pvagw.config &

# start the ioc
/epics/ioc/start.sh

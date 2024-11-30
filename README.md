# Demo of viewing Areadetector's PVAccess Plugin from a container network

Demonstrates the use of a pvxs server using 'name server' to get around issues with UDP broadcast into a container network. UDP does not work because the response does not get back through NAT.

This is intended for experimentation and is intended to be isolated to a single workstation.

## Running the demo IOC

```bash
./services/bl01t-launch.sh
```
This launches the IOC in a container but also configures and launches pvgw in the same container.

We do this because Areadetector does not use PVXS and therefore does not support nameserver. We use pvgw to bridge the gap. I believe that pvxs PVs would be addressable directly in this fashion and the gateway would not be necessary (not tested).

Key things to note. The ports are exposed as follows
```bash
args="--rm -it"
ca="-p 127.0.0.1:5064:5064/udp -p 127.0.0.1:5064-5065:5064-5065"
pva="-p 127.0.0.1:5076:5076/udp -p 127.0.0.1:5075:5075"
vols="-v /tmp:/tmp"
image="ghcr.io/epics-containers/pvagw-demo:2024.11.1"

set -x
$docker run $args $ca $pva $vols $image
```

## Running Phoebus to demonstrate a client seeing the PVAccess server

```bash
./opi/phoebus-launch.sh
```

Key things to note. The following setting tells Phoebus to use the local machine as a name server. Name server mode uses a single TCP connection only.
```
org.phoebus.pv.pva/epics_pva_name_servers=localhost
```

## PVAGateway config

Mostly default settings. The client addrlist is set to the container network broadcast address. This means the gateway is only looking for PVA servers inside the container network.

It was not possible to bind the PVA ports to localhost only as we do with CA. This is because the loopback adapter is used by PVA (I think in order to find other servers on the same host - avoiding the UNICAST issue CA has).

So this means that the pvgw may be getting requests from outside of the local workstation. However it meets the isolation requirement of the demo by only looking for servers in the container network.

Note that this approach can work with multiple containers as long as they are in the same container network.

## Notes

I have this working with podman 5.0.3. Interestingly this uses pasta networking and the container network is not NAT'd (containers get the same address and subnet as host). So potentially PVA might work in this scenario. But I've not worked out all the implications of this yet. I'm a little concerned that the isolation will fail in this case.

Right now when I run under docker I get the hosts broadcast address too and it is therefore not working. This is odd because if I exec in and check the broadcast address - it is the docker container one.

TODO: try this out on podman at DLS.

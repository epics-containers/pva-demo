# Demo of viewing Areadetector's PVAccess Plugin from a container network

Demonstrates the use of a pvxs server using 'name server' to get around issues with UDP broadcast into a container network. UDP does not work because the response does not get back through NAT.

This is intended for experimentation and is intended to be isolated to a single workstation.

## Running the demo in a developer container

Load the developer container and:

```bash
cd /epics/ioc
make
ibek dev instance /workspaces/pva-demo/services/bl01t-ea-ioc-02/
/workspaces/pva-demo/pvagw/pvagw-launch.sh
```

## Running the demo IOC without devcontainer

```bash
./services/bl01t-launch.sh
```
This launches the IOC in a container but also configures and launches pvgw in the same container.

We do this because Areadetector does not use PVXS and therefore does not support nameserver. We use pvgw to bridge the gap. I believe that pvxs PVs would be addressable directly in this fashion and the gateway would not be necessary (not tested).

Key things to note: The port 5075 is exposed on all interfaces as tcp only. UDP is not exposed as the broadcast will fail anyway. The 5075 port is used to make a TCP connection to the name server. This is an IANA assigned port for PVA see https://epics-controls.org/wp-content/uploads/2018/10/pvAccess-Protocol-Specification.pdf.


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

UPDATE: this also works with podman 4.9.4 at DLS. So the name server TCP connection is able to traverse a NAT. Thus this is a success.

TODO: test with docker.

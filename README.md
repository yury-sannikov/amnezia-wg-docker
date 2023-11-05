## About The Project
Microtic compatible Docker image to run Amnezia WG on Microtic routers. As of now, support Arm v7 boards

## About The Project
This is a highly experimental attempt to run [Amnezia-WG](https://github.com/amnezia-vpn/amnezia-wg) on a Microtic router.

### Prerequisites

Follow the [Microtic guidelines](https://help.mikrotik.com/docs/display/ROS/Container) to enable container support.

Install [Docker buildx](https://github.com/docker/buildx) subsystem, make and go.


### Building Docker Image

You may need to initialize submodules

```
git submodule init
git submodule update
```

To build a Docker container for the Microtic run
```
make microtic-arm7
```
This command should cross-compile amnezia-wg locally and then build a docker image for ArmV7 arch.

To export a generated image, use
```
make export-arm7
```

You will get the `microtic-awg-arm7.tar` archive ready to upload to the Microtic router.

### Running locally

Just run `docker compose up`

Make sure to create a `wg` folder with the `wg0.conf` file.

Example `wg0.conf`:

```
[Interface]
PrivateKey = gG...Y3s=
Address = 10.0.0.1/32
ListenPort = 51820
# Jc лучше брать в интервале [3,10], Jmin = 100, Jmax = 1000,
Jc = 3
Jmin = 100
Jmax = 1000
# Parameters below will not work with the existing WireGuarg implementation.
# Use if your peer running Amnesia-WG
# S1 = 324
# S2 = 452
# H1 = 25

# IP masquerading
PreUp = iptables -t nat -A POSTROUTING ! -o %i -j MASQUERADE
# Firewall wg peers from other hosts
PreUp = iptables -A FORWARD -o %i -m state --state ESTABLISHED,RELATED -j ACCEPT
PreUp = iptables -A FORWARD -o %i -j REJECT

# Remote settings for my workstation
[Peer]
PublicKey = wx...U=
AllowedIPs = 10.0.0.2/32
# An IP address to check peer connectivity (specific to this repo)
TestIP = 10.0.0.2
# Your existing Wireguard server
Endpoint=xx.xx.xx.xx:51820
PersistentKeepalive = 25

```

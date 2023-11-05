#! /bin/bash

# create /dev/net/tun if it does not exist
if [[ ! -c /dev/net/tun ]]; then
    mkdir -p /dev/net && mknod /dev/net/tun c 10 200
fi

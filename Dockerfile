ARG GOLANG_VERSION=1.21
ARG ALPINE_VERSION=3.18
FROM golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} AS builder

RUN apk update && apk add --no-cache git make bash build-base linux-headers
RUN git clone https://github.com/amnezia-vpn/amnezia-wg-tools.git
RUN cd amnezia-wg-tools/src && \
    make && \
    make install

FROM alpine:${ALPINE_VERSION}
RUN apk update && apk add --no-cache bash openrc iptables iproute2
COPY amnezia-wg/wireguard-go /usr/bin/amnezia-wg
COPY --from=builder /usr/bin/wg* /usr/bin/
COPY wireguard-fs /

RUN \
    sed -i 's/^\(tty\d\:\:\)/#\1/' /etc/inittab && \
    sed -i \
        -e 's/^#\?rc_env_allow=.*/rc_env_allow="\*"/' \
        -e 's/^#\?rc_sys=.*/rc_sys="docker"/' \
        /etc/rc.conf && \
    sed -i \
        -e 's/VSERVER/DOCKER/' \
        -e 's/checkpath -d "$RC_SVCDIR"/mkdir "$RC_SVCDIR"/' \
        /lib/rc/sh/init.sh && \
    rm \
        /etc/init.d/hwdrivers \
        /etc/init.d/machine-id
RUN    sed -i 's/cmd sysctl -q \(.*\?\)=\(.*\)/[[ "$(sysctl -n \1)" != "\2" ]] \&\& \0/' /usr/bin/wg-quick
RUN rc-update add wg-quick default


VOLUME ["/sys/fs/cgroup"]
ENV WG_SUDO=1
HEALTHCHECK --interval=15m --timeout=30s CMD /bin/bash /data/healthcheck.sh
CMD ["/sbin/init"]

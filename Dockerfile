ARG GOLANG_VERSION=1.21
ARG ALPINE_VERSION=3.19
FROM golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} AS builder

RUN apk update && apk add --no-cache git make bash build-base linux-headers
RUN git clone https://github.com/amnezia-vpn/amneziawg-tools.git
RUN cd amneziawg-tools/src && \
    make

FROM alpine:${ALPINE_VERSION}
RUN apk update && apk add --no-cache bash openrc iptables iptables-legacy iproute2
COPY amnezia-wg/amneziawg-go /usr/bin/amneziawg-go
COPY --from=builder /go/amneziawg-tools/src/wg /usr/bin/awg
COPY --from=builder /go/amneziawg-tools/src/wg-quick/linux.bash /usr/bin/awg-quick
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
RUN    sed -i 's/cmd sysctl -q \(.*\?\)=\(.*\)/[[ "$(sysctl -n \1)" != "\2" ]] \&\& \0/' /usr/bin/awg-quick
RUN \
    ln -s /sbin/iptables-legacy /bin/iptables && \
    ln -s /sbin/iptables-legacy-save /bin/iptables-save && \
    ln -s /sbin/iptables-legacy-restore /bin/iptables-restore
# register /etc/init.d/wg-quick
RUN rc-update add wg-quick default


VOLUME ["/sys/fs/cgroup"]
HEALTHCHECK --interval=15m --timeout=30s CMD /bin/bash /data/healthcheck.sh
CMD ["/sbin/init"]
EXPOSE 3478

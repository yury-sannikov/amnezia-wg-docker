#! /bin/bash


# Container healthcheck script
mapfile -t wg_elements < <( /usr/bin/awg )

if [ ${#wg_elements[@]} -gt 5 ]; then
        for key in "${!wg_elements[@]}"; do
                if [[ ${wg_elements[$key]} =~ "peer:" ]] || [[ ${wg_elements[$key]} =~ "handshake:" ]]; then
                        printf " ${wg_elements[$key]}:";
                fi
        done
        exit 0;
else
        echo "awg not started"
        exit 1;
fi

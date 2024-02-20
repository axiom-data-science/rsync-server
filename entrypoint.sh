#!/bin/bash
set -e
# AUTHORIZED_KEYS
USERNAME=${USERNAME:-user}
PASSWORD=${PASSWORD:-pass}
VOLUME=${VOLUME:-/data}
PUID=${PUID:-root}
GUID=${GUID:-root}
DENY=${DENY:-"*"}
ALLOW=${ALLOW:-10.0.0.0/8 192.168.0.0/16 172.16.0.0/12 127.0.0.1/32}
RO=${RO:-false}
# CUSTOMCONFIG


setup_sshd(){
	if [ -e "/root/.ssh/authorized_keys" ]; then
        chmod 400 /root/.ssh/authorized_keys
        chown root:root /root/.ssh/authorized_keys
    else
		mkdir -p /root/.ssh
		chown root:root /root/.ssh
		if [ ! -z "$AUTHORIZED_KEYS" ]; then
			echo "$AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
		fi
    fi
    chmod 750 /root/.ssh
    echo "root:$PASSWORD" | chpasswd
}

setup_rsyncd(){
	echo "$USERNAME:$PASSWORD" > /etc/rsyncd.secrets
    chmod 0400 /etc/rsyncd.secrets
	[ -f /etc/rsyncd.conf ] || cat > /etc/rsyncd.conf <<EOF
log file = /dev/stdout
timeout = 300
max connections = 10
port = 873

[volume]
	uid = ${PUID}
	gid = ${GUID}
	hosts deny = ${DENY}
	hosts allow = ${ALLOW}
	read only = ${RO}
	path = ${VOLUME}
	comment = ${VOLUME} directory
	auth users = ${USERNAME}
	secrets file = /etc/rsyncd.secrets
EOF

if [ ! -z "$CUSTOMCONFIG" ]; then
	echo -e "\t${CUSTOMCONFIG}" >> /etc/rsyncd.conf
fi
}


if [ "$1" = 'rsync_server' ]; then
    setup_sshd
    exec /usr/sbin/sshd &
    mkdir -p $VOLUME
    setup_rsyncd
    exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@"
else
	setup_sshd
	exec /usr/sbin/sshd &
fi

exec "$@"

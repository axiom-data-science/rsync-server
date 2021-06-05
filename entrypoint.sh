#!/bin/bash
set -e

USERNAME=${USERNAME:-user}
PASSWORD=${PASSWORD:-pass}
ALLOW=${ALLOW:-192.168.8.0/24 192.168.24.0/24 172.16.0.0/12 127.0.0.1/32}
DENY=${DENY:-*}
RSYNC_USER=${RSYNC_USER:-*}
SSH_USERS=${SSH_USERS}
VOLUME=${VOLUME:-/data}

setup_sshd(){
	if [ -e "/root/.ssh/authorized_keys" ]; then
        chmod 400 /root/.ssh/authorized_keys
        chown root:root /root/.ssh/authorized_keys
    else
		mkdir -p /root/.ssh
		chown root:root /root/.ssh
    fi
    chmod 750 /root/.ssh
    echo "root:$PASSWORD" | chpasswd
}

setup_users() {
	addgroup rsync
	for USER in $SSH_USERS; do
		echo 'Create user:' $USER
		useradd -ms /bin/bash $USER
		if [ -d "/home/$USER/" ]; then
			echo "Home directory '$USER' exist"
		else
			echo "Home directory '$USER' not exist and creating directory..."
			mkdir -p /home/$USER/
		fi
		usermod -a -G rsync $USER
		echo $USER:$(head -c64 /dev/urandom | base64) | chpasswd
		chmod 400 /home/$USER/.ssh/authorized_keys
		chown $USER:$USER /home/$USER/.ssh/authorized_keys
		chmod 750 /home/$USER/.ssh
		chown $USER:$USER /home/$USER/.ssh
	done
}

setup_rsyncd(){
	echo "$USERNAME:$PASSWORD" > /etc/rsyncd.secrets
    chmod 0400 /etc/rsyncd.secrets
	[ -f /etc/rsyncd.conf ] || cat > /etc/rsyncd.conf <<EOF
pid file = /var/run/rsyncd.pid
log file = /dev/stdout
timeout = 300
max connections = 10
port = 873

[volume]
	uid = root
	gid = root
	hosts deny = ${DENY}
	hosts allow = ${ALLOW}
	read only = false
	path = ${VOLUME}
	comment = ${VOLUME} directory
	auth users = ${RSYNC_USER}
	secrets file = /etc/rsyncd.secrets
EOF
}


if [ "$1" = 'rsync_server' ]; then
	setup_users
    setup_sshd
    exec /usr/sbin/sshd &
    mkdir -p $VOLUME
    setup_rsyncd
    exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@"
else
	setup_users
	setup_sshd
	exec /usr/sbin/sshd &
fi

exec "$@"

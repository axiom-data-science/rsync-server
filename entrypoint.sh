#!/bin/bash
set -e
# AUTHORIZED_KEYS
USERNAME=${USERNAME:-user}
VOLUME=${VOLUME:-/data}
PUID=${PUID:-root}
GUID=${GUID:-root}
DENY=${DENY:-"*"}
ALLOW=${ALLOW:-10.0.0.0/8 192.168.0.0/16 172.16.0.0/12 127.0.0.1/32}
RO=${RO:-false}
# CUSTOMCONFIG

# PASSWORD (required, specified directly with PASSWORD or via file contents with PASSWORD_FILE)
if [ -n "$PASSWORD_FILE" ]; then
    if [ ! -f "$PASSWORD_FILE" ]; then
        echo "PASSWORD_FILE $PASSWORD_FILE doesn't exist" >&2
        exit 1
    fi
    PASSWORD=$(cat "$PASSWORD_FILE")
fi
if [ -z "$PASSWORD" ]; then
    echo "Must provide rsync password using env var PASSWORD or PASSWORD_FILE (path to file containing password)" >&2
    exit 1
fi

check_permissions(){
    # Make sure target has uid 0, gid 0, and provided octal permissions
    TARGET_PATH="$1"
    TARGET_PERMISSIONS="$2"

    EXISTING_UID=$(stat -c "%u" "$TARGET_PATH")
    EXISTING_GID=$(stat -c "%g" "$TARGET_PATH")
    EXISTING_PERMISSIONS=$(stat -c "%a" "$TARGET_PATH")

    if [ "$EXISTING_UID" -ne "0" ] || [ "$EXISTING_GID" -ne "0" ]; then
        echo "$TARGET_PATH should have owner and group root, attempting chown" >&2
        chown root:root "$TARGET_PATH"
    fi

    if [ "$EXISTING_PERMISSIONS" -ne "$TARGET_PERMISSIONS" ]; then
        echo "$TARGET_PATH should have $TARGET_PERMISSIONS permissions (currently $EXISTING_PERMISSIONS), attempting chmod" >&2
        chmod "$TARGET_PERMISSIONS" "$TARGET_PATH"
    fi
}

setup_sshd(){
    SSH_DIR="/root/.ssh"
    AUTH_KEYS_PATH="${SSH_DIR}/authorized_keys"

    if [ ! -d "$SSH_DIR" ]; then
        install -d -m 700 "$SSH_DIR"
    fi
    check_permissions "$SSH_DIR" "700"

    if [ ! -z "$AUTHORIZED_KEYS" ]; then
        install -m 400 <(echo "$AUTHORIZED_KEYS") "$AUTH_KEYS_PATH"
    fi
    if [ -e "$AUTH_KEYS_PATH" ]; then
        check_permissions "$AUTH_KEYS_PATH" "400"
    fi

    echo "root:$PASSWORD" | chpasswd
}

setup_rsyncd(){
    echo "$USERNAME:$PASSWORD" > /etc/rsyncd.secrets
    chmod 0400 /etc/rsyncd.secrets
    [ -f /etc/rsyncd.conf ] || cat > /etc/rsyncd.conf <<EOF
log file = /dev/stderr
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

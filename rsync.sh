#!/bin/bash
set -e
#//////////////////////////////////////////////////////////////
#//   ____                                                   //
#//  | __ )  ___ _ __  ___ _   _ _ __   ___ _ __ _ __   ___  //
#//  |  _ \ / _ \ '_ \/ __| | | | '_ \ / _ \ '__| '_ \ / __| //
#//  | |_) |  __/ | | \__ \ |_| | |_) |  __/ |  | |_) | (__  //
#//  |____/ \___|_| |_|___/\__,_| .__/ \___|_|  | .__/ \___| //
#//                             |_|             |_|          //
#//////////////////////////////////////////////////////////////
#//                                                          //
#//  Script, 2021                                            //
#//  Created: 30, May, 2021                                  //
#//  Modified: 30, May, 2021                                 //
#//  file: -                                                 //
#//  -                                                       //
#//  Source: https://github.com/axiom-data-science/rsync-server                                               //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

DOCKER_IMAGE=bensuperpc/rsync-server:latest

USERNAME_SIZE=16
PASSWORD_SIZE=64

USERNAME=$(tr -dc A-Za-z </dev/urandom | head -c ${USERNAME_SIZE} ; echo '')
PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c ${PASSWORD_SIZE} ; echo '')

SSH_USERS="$@"

USER_VOL_KEY=""

echo 'USERNAME:' ${USERNAME}
echo 'PASSWORD:' ${PASSWORD}
echo 'Usage ex 1: rsync -azv -e "ssh -i <Private key> -p 9000 -l <USER>" localhost:/data/ $PWD'
echo 'Usage ex 2: rsync -azv rsync://'${USERNAME}'@localhost:8000/volume/ $PWD'
echo 'Replace <localhost> with <Your IP>'

setup_rsakey()
{
    mkdir -p $PWD/.ssh
    if [ ! -f $PWD/.ssh/$1 ]; then
        ssh-keygen -o -a 256 -b 512 -t ed25519 -C "ed25519-key" -f $PWD/.ssh/$1 -q -N ""
    else
        echo 'File:' $1 'exist.'
    fi
}

# Create multiple user
for USER in $SSH_USERS; do
    setup_rsakey "$USER"
    USER_VOL_KEY+=" -v  $PWD/.ssh/$USER.pub:/home/$USER/.ssh/authorized_keys"
done

# Create root user
setup_rsakey "root"

docker run \
    -v "$PWD/data":/data \
    -e USERNAME=${USERNAME} \
    -e PASSWORD=${PASSWORD} \
    -e VOLUME=/data \
    -e ALLOW="*" \
    -e DENY="" \
    -v $PWD/.ssh/root.pub:/root/.ssh/authorized_keys \
    -e SSH_USERS="${SSH_USERS}" \
    ${USER_VOL_KEY} \
    -p 9000:22 \
    -p 8000:873 \
    ${DOCKER_IMAGE}
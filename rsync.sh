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

echo 'USERNAME:' ${USERNAME}
echo 'PASSWORD:' ${PASSWORD}
echo 'Usage ex 1: rsync -azv -e "ssh -i ~/.ssh/id_rsa -p 9000 -l root" localhost:/data/ $PWD'
echo 'Usage ex 2: rsync -azv rsync://'${USERNAME}'@localhost:8000/volume/ $PWD'
echo 'Replace "localhost" with "Your IP"'

docker run \
    -v "$PWD/data":/data \
    -e USERNAME=${USERNAME} \
    -e PASSWORD=${PASSWORD} \
    -e VOLUME=/data \
    -e ALLOW="*" \
    -e DENY="" \
    -v ~/.ssh/id_rsa.pub:/root/.ssh/authorized_keys \
    -p 9000:22 \
    -p 8000:873 \
    ${DOCKER_IMAGE}
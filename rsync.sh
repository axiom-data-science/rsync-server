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

#    -e ALLOW="127.0.0.1/32" \
#    -p 8000:873 \
#    -e VOLUME=/data \
USERNAME=$(tr -dc A-Za-z </dev/urandom | head -c 16 ; echo '')
PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 64 ; echo '')

echo 'USERNAME:' ${USERNAME}
echo 'PASSWORD:' ${PASSWORD}
echo 'Usage ex 1: rsync -azv -e "ssh -i ~/.ssh/id_rsa -p 9000 -l root" localhost:/data/ $PWD'
echo 'Usage ex 2: rsync -azv rsync://'${USERNAME}'@localhost:8000/volume/ $PWD'
echo 'localhost: Your IP'

docker run \
    -v "$PWD/data":/data \
    -e USERNAME=${USERNAME} \
    -e PASSWORD=${PASSWORD} \
    -e VOLUME=/data \
    -e ALLOW="*" \
    -v ~/.ssh/id_rsa.pub:/root/.ssh/authorized_keys \
    -p 9000:22 \
    -p 8000:873 \
    bensuperpc/rsync-server:latest
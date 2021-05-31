#!/bin/python
#https://docker-py.readthedocs.io/en/stable/containers.html
import docker
from datetime import datetime

if __name__ == '__main__':

    client = docker.from_env()
    print('{} - Starting\n'.format(datetime.now()))
    _ports={'22/tcp': 9000}
    _environment={"PASSWORD": "xxx", 'USERNAME': 'yyy'}
    _volumes={'/home/bensuperpc/.ssh/id_rsa.pub': {'bind': '/root/.ssh/authorized_keys', 'mode': 'rw'},'/var/www': {'bind': '/mnt/vol1', 'mode': 'ro'}}
    print(client.containers.run('bensuperpc/rsync-server:latest', ports=_ports, environment=_environment,volumes=_volumes ))

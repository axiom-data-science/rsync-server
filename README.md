## rsync-server

A simple `rsync` server in Docker


### Usage

Variable options (on run)

* `USERNAME` - the `rsync` username. defaults to `user`
* `PASSWORD` - the `rsync` password. defaults to `pass`
* `VOLUME`   - the path for `rsync`. defaults to `/data`
* `ALLOW`    - space separated list of allowed sources. defaults to `192.168.0.0/16 172.16.0.0/12`.

##### Simple server on port 873

```
docker run -p 873:873 axiom/rsync-server
```

```
rsync rsync://localhost:873
volume            /data directory
```

##### Use a volume for the default `/data`

```
docker run -p 873:873 -v /your/folder:/data axiom/rsync-server
```

```
rsync rsync://localhost:873
volume            /data directory
```

##### Set a username and password

```
docker run \
    -p 873:873 \
    -v /your/folder:/data \
    -e USERNAME=admin \
    -e PASSWORD=mysecret \
    axiom/rsync-server
```

```
rsync rsync://admin@localhost:873
Password:
volume            /data directory
```

##### Run on a custom port

```
docker run \
    -p 9999:873 \
    -v /your/folder:/data \
    -e USERNAME=admin \
    -e PASSWORD=mysecret \
    axiom/rsync-server
```

```
rsync rsync://admin@localhost:9999
Password:
volume            /data directory
```


##### Modify the default volume location

```
docker run \
    -p 9999:873 \
    -v /your/folder:/myvolume \
    -e USERNAME=admin \
    -e PASSWORD=mysecret \
    -e VOLUME=/myvolume \
    axiom/rsync-server
```

```
rsync rsync://admin@localhost:9999
Password:
volume            /myvolume directory
```

##### Allow additional client IPs

```
docker run \
    -p 9999:873 \
    -v /your/folder:/myvolume \
    -e USERNAME=admin \
    -e PASSWORD=mysecret \
    -e VOLUME=/myvolume \
    -e ALLOW=192.168.8.0/24 192.168.24.0/24 172.16.0.0/12 127.0.0.1/32
    axiom/rsync-server
```

```
rsync rsync://admin@localhost:9999
Password:
volume            /myvolume directory
```


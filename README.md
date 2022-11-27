## rsync-server

A `rsyncd`/`sshd` server in Docker. You know, for moving files.


### quickstart

Start a server (both `sshd` and `rsyncd` are supported)

```
$ docker run \
    --name rsync-server \ # Name it
    -p 8000:873 \ # rsyncd port
    -p 9000:22 \ # sshd port
    -e USERNAME=user \ # rsync username
    -e PASSWORD=pass \ # rsync/ssh password
    -v /your/public.key:/root/.ssh/authorized_keys \ # your public key
    axiom/rsync-server
```

**Warning** If you are exposing services to the internet be sure to change the default password from `pass` by settings the environmental variable `PASSWORD`.

#### `rsyncd`

Please note that `/volume` is the `rsync` volume pointing to `/data`. The data
will be at `/data` in the container. Use the `VOLUME` parameter to change the
destination path in the container. Even when changing `VOLUME`, you will still
`rsync` to `/volume`. **It is recommended that you always change the default password of `pass` by setting the `PASSWORD` environmental variable, even if you are using key authentication.**

```
$ rsync -av /your/folder/ rsync://user@localhost:8000/volume
Password: pass
sending incremental file list
./
foo/
foo/bar/
foo/bar/hi.txt

sent 166 bytes  received 39 bytes  136.67 bytes/sec
total size is 0  speedup is 0.00
```


#### `sshd`

Please note that you are connecting as the `root` and not the user specified in
the `USERNAME` variable. If you don't supply a key file you will be prompted
for the `PASSWORD`. **It is recommended that you always change the default password of `pass` by setting the `PASSWORD` environmental variable, even if you are using key authentication.**

```
$ rsync -av -e "ssh -i /your/private.key -p 9000 -l root" /your/folder/ localhost:/data
sending incremental file list
./
foo/
foo/bar/
foo/bar/hi.txt

sent 166 bytes  received 31 bytes  131.33 bytes/sec
total size is 0  speedup is 0.00
```


### Usage

Variable options (on run)

* `USERNAME` - the `rsync` username. defaults to `user`
* `PASSWORD` - the `rsync` password. defaults to `pass`
* `VOLUME`   - the path for `rsync`. defaults to `/data`
* `ALLOW`    - space separated list of allowed sources. defaults to `10.0.0.0/8 172.16.0.0/12 192.168.0.0/16`.


##### Simple server on port 873

```
$ docker run -p 873:873 axiom/rsync-server
```


##### Use a volume for the default `/data`

```
$ docker run -p 873:873 -v /your/folder:/data axiom/rsync-server
```

##### Set a username and password

```
$ docker run \
    -p 873:873 \
    -v /your/folder:/data \
    -e USERNAME=admin \
    -e PASSWORD=mysecret \
    axiom/rsync-server
```

##### Run on a custom port

```
$ docker run \
    -p 9999:873 \
    -v /your/folder:/data \
    -e USERNAME=admin \
    -e PASSWORD=mysecret \
    axiom/rsync-server
```

```
$ rsync rsync://admin@localhost:9999
volume            /data directory
```


##### Modify the default volume location

```
$ docker run \
    -p 9999:873 \
    -v /your/folder:/myvolume \
    -e USERNAME=admin \
    -e PASSWORD=mysecret \
    -e VOLUME=/myvolume \
    axiom/rsync-server
```

```
$ rsync rsync://admin@localhost:9999
volume            /myvolume directory
```

##### Allow additional client IPs

```
$ docker run \
    -p 9999:873 \
    -v /your/folder:/myvolume \
    -e USERNAME=admin \
    -e PASSWORD=mysecret \
    -e VOLUME=/myvolume \
    -e ALLOW=10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 \
    axiom/rsync-server
```


##### Over SSH

If you would like to connect over ssh, you may mount your public key or
`authorized_keys` file to `/root/.ssh/authorized_keys`.

Without setting up an `authorized_keys` file, you will be propted for the
password (which was specified in the `PASSWORD` variable).

Please note that when using `sshd` **you will be specifying the actual folder
destination as you would when using SSH.** On the contrary, when using the
`rsyncd` daemon, you will always be using `/volume`, which maps to `VOLUME`
inside of the container.

```
docker run \
    -v /your/folder:/myvolume \
    -e USERNAME=admin \
    -e PASSWORD=mysecret \
    -e VOLUME=/myvolume \
    -e ALLOW=10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 \
    -v /my/authorized_keys:/root/.ssh/authorized_keys \
    -p 9000:22 \
    axiom/rsync-server
```

```
$ rsync -av -e "ssh -i /your/private.key -p 9000 -l root" /your/folder/ localhost:/data
```

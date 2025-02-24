# THIS PROJECT IS UNMAINTAINED AND ARCHIVED. USE AT YOUR OWN RISK.

# rsync-server

A `rsyncd`/`sshd` server in Docker. You know, for moving files.

## Quickstart

Start a server (both `sshd` and `rsyncd` are supported)

```shell
docker run \
    --name rsync-server \
    -p 8000:873 \
    -p 9000:22 \
    -e USERNAME=user \
    -e PASSWORD=someSecurePassword_NOT_THIS \
    -v /your/public.key:/root/.ssh/authorized_keys \
    axiom/rsync-server:latest
```

**You must set a password via `PASSWORD` or `PASSWORD_FILE`, even if you are using key authentication.**

### `rsyncd`

Please note that `/volume` is the `rsync` volume pointing to `/data`. The data
will be at `/data` in the container. Use the `VOLUME` parameter to change the
destination path in the container. Even when changing `VOLUME`, you will still
`rsync` to `/volume`.

```shell
rsync -av /your/folder/ rsync://user@localhost:8000/volume
Password: pass

sending incremental file list
./
foo/
foo/bar/
foo/bar/hi.txt

sent 166 bytes  received 39 bytes  136.67 bytes/sec
total size is 0  speedup is 0.00
```

### `sshd`

Please note that you are connecting as the `root` and not the user specified in
the `USERNAME` variable. If you don't supply a key file you will be prompted
for the `PASSWORD`.

```shell
rsync -av -e "ssh -i /your/private.key -p 9000 -l root" /your/folder/ localhost:/data

sending incremental file list
./
foo/
foo/bar/
foo/bar/hi.txt

sent 166 bytes  received 31 bytes  131.33 bytes/sec
total size is 0  speedup is 0.00
```

## Usage

Variable options (on run)

|     Parameter     | Function |
| :---------------: | -------- |
| `USERNAME`        | the `rsync` username. defaults to `user`|
| `PASSWORD`        | the `rsync` password. **One of `PASSWORD` or `PASSWORD_FILE` is required.**|
| `PASSWORD_FILE`   | path to a file containing the `rsync` password. **One of `PASSWORD` or `PASSWORD_FILE` is required.**|
| `AUTHORIZED_KEYS` | the `ssh` key (for root user). defaults empty |
| `VOLUME`   | the path for `rsync`. defaults to `/data`|
| `PUID`     | UserID used to transfer files when running the rsync . defaults to `root`|
| `GUID`     | GroupID used to transfer files when running the rsync . defaults to `root`|
| `DENY`     | space separated list of allowed sources. defaults to `*`|
| `ALLOW`    | space separated list of allowed sources. defaults to `10.0.0.0/8 192.168.0.0/16 172.16.0.0/12 127.0.0.1/32`.|
| `RO`     | `rsync` volume read only. defaults to `false`|
| `CUSTOMCONFIG` | rsyncd.conf custom config for subsection volume (`\n\t` for new line ex: `uid = root\n\tgid = root`). defaults empty |

### Simple server on port 873

```shell
docker run -p 873:873 -e PASSWORD=changeme axiom/rsync-server:latest
```

### Use a volume for the default `/data`

```shell
docker run -p 873:873 -e PASSWORD=seriouslychangeme -v /your/folder:/data axiom/rsync-server:latest
```

### Set a username and password

```shell
docker run \
    -p 873:873 \
    -v /your/folder:/data \
    -e USERNAME=admin \
    -e PASSWORD=imnotkidding \
    axiom/rsync-server:latest
```

### Set password via file

```shell
docker run \
    -p 873:873 \
    -v /your/folder:/data \
    -v ./password-file-with-secure-permissions:/etc/rsyncd/password:ro \
    -e USERNAME=admin \
    -e PASSWORD_FILE=/etc/rsyncd/password \
    axiom/rsync-server:latest
```

### Run on a custom port

```shell
docker run \
    -p 9999:873 \
    -v /your/folder:/data \
    -e USERNAME=admin \
    -e PASSWORD=plzchng \
    axiom/rsync-server:latest
```

```shell
rsync rsync://admin@localhost:9999

volume            /data directory
```

### Modify the default volume location

```shell
docker run \
    -p 9999:873 \
    -v /your/folder:/myvolume \
    -e USERNAME=admin \
    -e PASSWORD=yougetitnow \
    -e VOLUME=/myvolume \
    axiom/rsync-server:latest
```

```shell
rsync rsync://admin@localhost:9999

volume            /myvolume directory
```

### Allow specific client IPs

```shell
docker run \
    -p 9999:873 \
    -v /your/folder:/myvolume \
    -e USERNAME=admin \
    -e PASSWORD=hopesoanyway \
    -e VOLUME=/myvolume \
    -e ALLOW=192.168.24.0/24 \
    axiom/rsync-server:latest
```

### Over SSH

If you would like to connect over ssh, you may mount your public key or
`authorized_keys` file to `/root/.ssh/authorized_keys`. This file
must have owner root, group root, and 400 octal permissions.

Alternatively, you may specify the `AUTHORIZED_KEYS` environment variable.

Without setting up an `authorized_keys` file, you will be propted for the
password (which was specified in the `PASSWORD` variable).

Please note that when using `sshd` **you will be specifying the actual folder
destination as you would when using SSH.** On the contrary, when using the
`rsyncd` daemon, you will always be using `/volume`, which maps to `VOLUME`
inside of the container.

```shell
docker run \
    -v /your/folder:/myvolume \
    -e USERNAME=admin \
    -e PASSWORD=2manyp455w0rd5 \
    -e VOLUME=/myvolume \
    -e ALLOW=10.0.0.0/8 192.168.0.0/16 172.16.0.0/12 127.0.0.1/32 \
    -v /my/authorized_keys:/root/.ssh/authorized_keys \
    -p 9000:22 \
    axiom/rsync-server:latest
```

```shell
rsync -av -e "ssh -i /your/private.key -p 9000 -l root" /your/folder/ localhost:/data
```

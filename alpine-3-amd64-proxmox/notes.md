# scratchpad


### Docker
```
apk add docker-engine@edgecommunity docker-openrc@edgecommunity docker-cli@edgecommunity docker@edgecommunity
docker --version

apk add py3-setuptools python3-dev libffi-dev openssl-dev gcc libc-dev make
pip3 install --upgrade pip
pip3 install docker-compose
docker-compose --version
```
or

```
apk add docker-compose@edgecommunity
docker-compose --version
```

### boot command:
`openntpd` missing (error)

### qemu guest

```
host:~# cat /etc/conf.d/qemu-guest-agent
# Specifies the transport method used to communicate to QEMU on the host side
# Default: virtio-serial
#GA_METHOD="virtio-serial"

# Specifies the device path for the communications back to QEMU on the host
# Default: /dev/virtio-ports/org.qemu.guest_agent.0
GA_PATH="/dev/vport1p1"
```

set -ux

# adding repositories needed for cloud-init
echo "http://nl.alpinelinux.org/alpine/v3.10/community" >> /etc/apk/repositories
echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
echo "@edgecommunity http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

# update all packages, including the kernel.
apk update
apk upgrade

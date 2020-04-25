set -ux

# MOVED TO ANSIBLE

# # adding additional repositories
echo "http://nl.alpinelinux.org/alpine/v3.11/community" >> /etc/apk/repositories
echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
#echo "@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
#
# # update all packages, including the kernel.
apk update
apk upgrade

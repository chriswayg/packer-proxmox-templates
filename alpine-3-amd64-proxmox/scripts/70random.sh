set -eux

# Fixes: Boot delay/issues because of limited entropy (fixed in Alpine 3.11)
# https://gitlab.alpinelinux.org/alpine/aports/issues/9960
#apk add haveged
#rc-update add haveged boot

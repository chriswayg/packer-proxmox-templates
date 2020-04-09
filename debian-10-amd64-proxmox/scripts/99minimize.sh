set -x

echo "minimize image size"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

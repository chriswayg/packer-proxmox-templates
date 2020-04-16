set -ux

apk upgrade -U --available

source /etc/os-release

cat > /etc/motd << "EOF"

 $PRETTY_NAME ($VERSION_ID) Cloud Server

EOF

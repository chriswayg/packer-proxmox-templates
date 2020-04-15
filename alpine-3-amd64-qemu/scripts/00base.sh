set -ux

apk upgrade -U --available

source /etc/os-release

printf "\n $PRETTY_NAME ($VERSION_ID) Cloud Server\n\n" > /etc/motd

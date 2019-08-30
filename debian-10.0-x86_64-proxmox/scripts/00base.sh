set -ex
export DEBIAN_FRONTEND=noninteractive

echo "removing xll packages (server not desktop...)"
apt-get -y remove libx11.*

echo "move original /etc/apt/sources.list to back it up"
mv /etc/apt/sources.list /etc/apt/sources.list.original

echo "Configure nearest apt repositories"
cat > /etc/apt/sources.list << "EOF"
deb http://repo.myloc.de/debian buster main non-free contrib
deb-src http://repo.myloc.de/debian buster main non-free contrib

deb http://security.debian.org/debian-security buster/updates main contrib non-free
deb-src http://security.debian.org/debian-security buster/updates main contrib non-free

deb http://deb.debian.org/debian buster-updates main contrib non-free
deb-src http://deb.debian.org/debian buster-updates main contrib non-free
EOF

echo "update and upgrade remaining packages"
apt-get -y update
apt-get -y upgrade

echo "install some basic utilities"
apt-get -y install curl bzip2 psmisc net-tools

echo "purging packages which are no longer needed"
apt-get -y autoremove

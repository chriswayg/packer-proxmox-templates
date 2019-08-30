set -ex
export DEBIAN_FRONTEND=noninteractive

echo "removing xll packages (server not desktop...)"
apt-get -y remove libx11.*

echo "move original /etc/apt/sources.list to back it up"
mv /etc/apt/sources.list /etc/apt/sources.list.original

echo "Configure nearest apt repositories"
cat > /etc/apt/sources.list << "EOF"
deb http://repo.myloc.de/ubuntu/ bionic main restricted universe multiverse
deb-src http://repo.myloc.de/ubuntu/ bionic main restricted universe multiverse

deb http://repo.myloc.de/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://repo.myloc.de/ubuntu/ bionic-updates main restricted universe multiverse

deb http://repo.myloc.de/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://repo.myloc.de/ubuntu/ bionic-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu bionic-security main restricted universe multiverse
deb-src http://security.ubuntu.com/ubuntu bionic-security main restricted universe multiverse
EOF

echo "update and upgrade remaining packages"
apt-get -y update
apt-get -y upgrade

echo "install some basic utilities; cloud-guest for growpart"
apt-get -y install curl psmisc net-tools cloud-guest-utils

echo "purging packages which are no longer needed"
apt-get -y autoremove

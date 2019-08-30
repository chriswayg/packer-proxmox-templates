set -x

# remove x11 (it's a server...)
apt-get -y remove libx11.*
apt-get -y autoremove
apt-get -y clean

echo "cleaning up dhcp leases"
rm /var/lib/dhcp/* 2>/dev/null

echo "cleaning bash history"
unset HISTFILE
rm ~/.bash_history /home/ubuntu/.bash_history 2>/dev/null

exit 0

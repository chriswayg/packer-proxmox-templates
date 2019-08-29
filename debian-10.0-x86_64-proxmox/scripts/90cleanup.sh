set -x

echo "cleaning up dhcp leases"
rm /var/lib/dhcp/* 2>/dev/null

echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules 2>/dev/null
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm /lib/udev/rules.d/75-persistent-net-generator.rules 2>/dev/null
rm -rf /dev/.udev/ 2>/dev/null

echo "cleaning bash history"
unset HISTFILE
rm ~/.bash_history /home/debian/.bash_history 2>/dev/null

exit 0

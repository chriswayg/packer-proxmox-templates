set -ex

echo "set hostname plus domainname and add these to /etc/hosts"
namehost=deb10-kvm
namedomain=unassigned.domain
hostnamectl set-hostname ${namehost}
#domainname ${namedomain}
cp -v /etc/hosts /etc/hosts.original
sed -i "/^127.0.1.1/c\127.0.1.1       ${namehost}.${namedomain}  ${namehost}" /etc/hosts

echo "Create a script which will run when the network comes up to display IP before login"

cp /etc/issue /etc/issue.original

cat > /etc/networkd-dispatcher/routable.d/99-show-ip-address << "EOF"
#!/bin/bash
cp /etc/issue.original /etc/issue
printf "SSH key fingerprint: \n$(ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub)\n\n" >> /etc/issue
printf "Server Network Interface: $(ip -4 -br addr |  sed -n '2p')\n\n" >> /etc/issue
EOF

chmod +x /etc/networkd-dispatcher/routable.d/99-show-ip-address

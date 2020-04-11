set -eux

# RootLogin without password was permitted in order to allow packer ssh access
# to provision the system. Its removed here to make the server more secure.
sed -i "/^PermitRootLogin/c\PermitRootLogin no" /etc/ssh/sshd_config

# UseDNS value is No which avoids login delays when the remote client's DNS cannot be resolved
sed -i "/^UseDNS/c\UseDNS no" /etc/ssh/sshd_config

# disable ssh password authentication
sed -i "/^PasswordAuthentication/c\PasswordAuthentication no" /etc/ssh/sshd_config

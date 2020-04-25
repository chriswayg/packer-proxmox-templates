set -eux

# RootLogin with a password was permitted in order to allow packer ssh access
# to provision the system. Its removed here to make the server more secure.
sed -i '/^PermitRootLogin yes/d' /etc/ssh/sshd_config

# disable ssh password authentication
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

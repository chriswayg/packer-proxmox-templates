set -eux

echo "Activate authorized key for SSH login and disable Password Authentication"
mkdir -pv /home/christian/.ssh

cat > /home/christian/.ssh/authorized_keys << "EOF"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDK1zNq5zsVbbN/gLdYqxlb5CROsR1dBNBgRFzzCJUL3ncU2dDHLHWi0L/FafwWt6MQ7vePu7catLDegY2fs1QB0KYvy21fD3+9ONBs7KcFlmuyqjLJ9VAoLWW5Tv3I9eZNgpd9k6CvYphKa1Owq43ye+quQRI4J+2nb7Zhl2WTQ1N2WBwZbmf0ErTHwa+mC7frTRBYh6ddyXp9KRULH89y/6cVpL6uQyFzIr6yWowUbJ8lX3fA9e7RAxkG76X54sMa65oq3Bog04ylJ4n/xZCXO449BZjAZHcJuDcFLXrwIo52t+Q6gIEnXInTiii26/ZWbnzzheggjkpQ77tCg03t christian@Chris-GigaMac.local
EOF

chown -Rv christian:christian /home/christian/.ssh
chmod -v 700 /home/christian/.ssh
chmod -v 600 /home/christian/.ssh/authorized_keys

# RootLogin without password was permitted in order to allow packer ssh access
# to provision the system. Its removed here to make the server more secure.
sed -i '/^PermitRootLogin no/d' /etc/ssh/sshd_config

# disable ssh password authentication
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

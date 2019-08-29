set -ex

echo "Add a nice greeting - motd"
mv /etc/motd /etc/motd.original

cat > /etc/update-motd.d/20-motd-welcome << "EOF"
#!/bin/bash
source /etc/os-release
echo ""
echo " Welcome to $PRETTY_NAME Server"
echo ""
EOF

chmod +x /etc/update-motd.d/20-motd-welcome

echo "Customize Bashrc with color and prompt"

cat >> /root/.bashrc  << "EOF"
export PS1="\[\033[1;31m\][\u@\h:\w]#\[\033[0m\] "
EOF
sed -i 's/# export LS_OPTIONS=/export LS_OPTIONS=/g' /root/.bashrc
sed -i 's/# eval/eval/g' /root/.bashrc
sed -i 's/# alias l/alias l/g' /root/.bashrc

cat >> /home/debian/.bashrc << "EOF"
export PS1="\[\033[1;34m\][\u@\h:\w]$\[\033[0m\] "
EOF
sed -i 's/# export LS_OPTIONS=/export LS_OPTIONS=/g' /home/debian/.bashrc
sed -i 's/# eval/eval/g' /home/debian/.bashrc
sed -i 's/# alias l/alias l/g' /home/debian/.bashrc

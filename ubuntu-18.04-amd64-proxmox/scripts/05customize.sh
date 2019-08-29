set -ex

echo "Remove Ubuntu help text from motd"
rm -v /etc/update-motd.d/10-help-text

echo "Customize Bashrc with color and prompt"

cat >> /root/.bashrc  << "EOF"
export PS1="\[\033[1;31m\][\u@\h:\w]#\[\033[0m\] "
EOF
sed -i 's/# export LS_OPTIONS=/export LS_OPTIONS=/g' /root/.bashrc
sed -i 's/# eval/eval/g' /root/.bashrc
sed -i 's/# alias l/alias l/g' /root/.bashrc

cat >> /home/ubuntu/.bashrc << "EOF"
export PS1="\[\033[1;34m\][\u@\h:\w]$\[\033[0m\] "
EOF
sed -i 's/# export LS_OPTIONS=/export LS_OPTIONS=/g' /home/ubuntu/.bashrc
sed -i 's/# eval/eval/g' /home/ubuntu/.bashrc
sed -i 's/# alias l/alias l/g' /home/ubuntu/.bashrc

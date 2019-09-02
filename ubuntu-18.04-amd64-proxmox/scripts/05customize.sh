set -ex

echo "Remove Ubuntu help-text and ads from motd"
rm -v /etc/update-motd.d/10-help-text
sed -i "/^ENABLED=/c\ENABLED=0" /etc/default/motd-news


echo "Customize Bashrc with color and prompt"

cat >> /root/.bashrc  << "EOF"
export PS1="\[\033[1;31m\][\u@\h:\w]#\[\033[0m\] "
EOF
sed -i 's/# export LS_OPTIONS=/export LS_OPTIONS=/g' /root/.bashrc
sed -i 's/# eval/eval/g' /root/.bashrc
sed -i 's/# alias l/alias l/g' /root/.bashrc

cat >> /home/deploy/.bashrc << "EOF"
export PS1="\[\033[1;34m\][\u@\h:\w]$\[\033[0m\] "
EOF
sed -i 's/# export LS_OPTIONS=/export LS_OPTIONS=/g' /home/deploy/.bashrc
sed -i 's/# eval/eval/g' /home/deploy/.bashrc
sed -i 's/# alias l/alias l/g' /home/deploy/.bashrc

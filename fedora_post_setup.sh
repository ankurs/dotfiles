#!/bin/bash -e

echo "installing brave-browser"
sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser -y

echo "setting up fail2ban"
sudo cp -n ./fedora/fail2ban/jail.d/99-local.conf /etc/fail2ban/jail.d/
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
sudo fail2ban-client status

echo "setting up sysctl options"
sudo cp -n ./fedora/sysctl.d/90-ankur.conf /etc/sysctl.d/90-ankur.conf
sudo sysctl --system

echo "add $USER to docker group"
sudo usermod -aG docker $USER

echo "setting up systemctl"
sudo systemctl enable sshd
sudo systemctl start sshd
sudo systemctl start docker
sudo systemctl enable docker


# setup noatime for ssd ?
#lsblk -d -o name,rota,type | grep disk

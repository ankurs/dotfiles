#!/bin/bash -e
############ SYSTEM ###############
read -p "Do you wish to install brave-browser ? [y/N]? " brave
if [[ x$brave == xy || x$brave == xY ]]
then
    sudo dnf install dnf-plugins-core
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo dnf install brave-browser -y
fi

read -p "Do you wish to install google-chrome ? [y/N]? " chrome
if [[ x$chrome == xy || x$chrome == xY ]]
then
    sudo dnf install fedora-workstation-repositories -y
    sudo dnf config-manager --set-enabled
    sudo dnf install google-chrome-stable -y
fi

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

echo "setting up systemctl"
sudo systemctl enable sshd
sudo systemctl start sshd
sudo systemctl start docker
sudo systemctl enable docker

# setup noatime for ssd ?
#lsblk -d -o name,rota,type | grep disk

##########  USER ##############
echo "add $USER to docker group"
sudo usermod -aG docker $USER

echo "updating shell to zsh"
chsh -s $(which zsh)

########## EXTRA #############
read -p "Do you wish to install Virtulization tools ? [y/N]? " virt
if [[ x$virt == xy || x$virt == xY ]]
then
    bash -e fedora/virt.sh
fi

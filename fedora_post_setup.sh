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
    sudo dnf config-manager --set-enabled google-chrome
    sudo dnf install google-chrome-stable -y
fi

echo "setting up fail2ban"
sudo cp -i ./fedora/fail2ban/jail.d/99-local.conf /etc/fail2ban/jail.d/
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
sudo fail2ban-client status

echo "setting up sysctl options"
sudo cp -i ./fedora/sysctl.d/90-ankur.conf /etc/sysctl.d/90-ankur.conf
sudo sysctl --system

echo "setting up systemctl"
sudo systemctl enable sshd
sudo systemctl start sshd
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl start netdata
sudo systemctl enable netdata

# setup noatime for ssd ?
#lsblk -d -o name,rota,type | grep disk

read -p "Do you wish to set up google drive fuse ?[y/N]? " drive
if [[ x$drive == xy || x$drive == xY ]]
then
    opam init
    opam update
    opam install depext
    opam depext google-drive-ocamlfuse
    opam install google-drive-ocamlfuse
    mkdir -p ~/GoogleDrive/My\ Drive
    echo "please run 'google-drive-ocamlfuse' for setup and then mount the volume by using 'gdrive' alias"
fi

##########  USER ##############
echo "add $USER to docker group"
sudo usermod -aG docker $USER

echo "updating shell to zsh"
chsh -s $(which zsh)

mkdir -p ~/.config/variety
cp -i ./variety.conf ~/.config/variety/variety.conf

########## EXTRA #############
read -p "Do you wish to install Virtulization tools ? [y/N]? " virt
if [[ x$virt == xy || x$virt == xY ]]
then
    bash -e fedora/virt.sh
fi

read -p "Do you wish to install laptop power management tools [y/N]? " lap
if [[ x$lap == xy || x$lap == xY ]]
then
    bash -e fedora/laptop.sh
fi


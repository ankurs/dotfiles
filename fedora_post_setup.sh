#!/bin/bash -e
############ SYSTEM ###############
read -p "Do you wish to install brave-browser ? [y/N]? " brave
if [[ x$brave == xy || x$brave == xY ]]
then
    sudo dnf install dnf-plugins-core
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
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

echo "setting up flathub"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

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

echo "setting up nodejs :("
mkdir -p ~/.node
echo "prefix = ~/.node" > ~/.npmrc
sudo dnf install nodejs npm
npm install -g esctags

##########  USER ##############
echo "add $USER to docker group"
sudo usermod -aG docker $USER

echo "updating shell to zsh"
chsh -s $(which zsh)

mkdir -p ~/.config/variety
cp -i ./variety.conf ~/.config/variety/variety.conf

mkdir -p ~/.config/rofi
ln -s -i `pwd`/fedora/config.rasi ~/.config/rofi/config.rasi

########## EXTRA #############
read -p "Do you wish to install Virtulization tools ? [y/N]? " virt
if [[ x$virt == xy || x$virt == xY ]]
then
    bash -e fedora/virt.sh
    echo "adding $USER to kvm group"
    sudo usermod -aG kvm $USER
fi

read -p "Do you wish to install laptop power management tools [y/N]? " lap
if [[ x$lap == xy || x$lap == xY ]]
then
    bash -e fedora/laptop.sh
fi

read -p "Do you wish to install OpenZFS [y/N]? " zfs
if [[ x$zfs == xy || x$zfs == xY ]]
then
    bash -e fedora/openzfs.sh
fi

read -p "Do you wish to install Minikube [y/N]? " kube
if [[ x$kube == xy || x$kube == xY ]]
then
    bash -e fedora/minikube.sh
fi

read -p "Do you wish to install Sway [y/N]? " sway
if [[ x$sway == xy || x$sway == xY ]]
then
    mkdir -p ~/.config/sway
    mkdir -p ~/.config/waybar
    mkdir -p ~/.config/wofi
    mkdir -p ~/.config/swaylock
    PWD=`pwd`
    ln -s -i $PWD/sway-config ~/.config/sway/config
    ln -s -i $PWD/waybar-config ~/.config/waybar/config
    ln -s -i $PWD/waybar-style.css ~/.config/waybar/style.css
    ln -s -i $PWD/wofi-styles.css ~/.config/wofi/styles.css
    ln -s -i $PWD/swaylock.conf ~/.config/swaylock/config
    sudo dnf install sway swayidle swaylock swaybg nwg-launchers nwg-panel rofi waybar wofi wlogout grim slurp -y
    sudo dnf copr enable erikreider/SwayNotificationCenter
    sudo dnf install SwayNotificationCenter
fi
#cat  /usr/share/wayland-sessions/sway.desktop
#[Desktop Entry]
#Name=Sway
#Comment=An i3-compatible Wayland compositor
#Exec=env WLR_NO_HARDWARE_CURSORS=1 sway
#Type=Application

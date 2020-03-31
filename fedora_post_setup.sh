#!/bin/bash -e
echo "setting up systemctl"
sudo systemctl enable sshd
sudo systemctl start sshd
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

## install brave
sudo dnf install dnf-plugins-core

sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/

sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

sudo dnf install brave-browser -y

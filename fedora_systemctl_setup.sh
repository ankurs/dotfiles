#!/bin/bash -e
echo "setting up systemctl"
sudo systemctl enable sshd
sudo systemctl start sshd
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

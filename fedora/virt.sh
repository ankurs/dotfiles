#!/bin/bash -e
sudo dnf group install --with-optional virtualization -y
sudo usermod --append --groups libvirt $USER
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

#doc - https://wiki.libvirt.org/page/Networking

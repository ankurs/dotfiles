#!/bin/bash -e
sudo dnf group install --with-optional virtualization
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

#doc - https://wiki.libvirt.org/page/Networking

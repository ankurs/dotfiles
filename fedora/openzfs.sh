#!/bin/bash -e
sudo dnf install http://download.zfsonlinux.org/fedora/zfs-release$(rpm -E %dist).noarch.rpm
#gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
sudo dnf install kernel-devel zfs -y --allowerasing
#sudo dnf swap zfs-fuse zfs -y

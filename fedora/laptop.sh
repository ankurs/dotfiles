#!/bin/bash -e
echo "Setting up tlp"
sudo dnf install tlp tlp-rdw powertop -y
sudo systemctl enable tlp
sudo systemctl start tlp
sudo tlp start

#!/bin/bash -e
echo "Installing packages"
sudo dnf install tlp tlp-rdw powertop lm_sensors mbpfan -y
echo "Setting up tlp"
sudo systemctl enable tlp
sudo systemctl start tlp
sudo tlp start

systemctl enable mbpfan
systemctl start mbpfan

echo "setting up sensors"
sudo sensors-detect

echo "setting up xsensors"
sudo dnf install xsensors -y

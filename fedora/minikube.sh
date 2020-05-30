#!/bin/bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -ivh minikube-latest.x86_64.rpm
rm -rf minikube-latest.x86_64.rpm
minikube config set driver kvm2
#minikube start --driver=kvm2

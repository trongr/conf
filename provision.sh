#!/bin/bash

# installs tools on a fresh ubuntu box

sudo apt-get update

sudo apt-get install -y build-essential git nginx emacs

sudo apt-get install -y nodejs
sudo npm install -g express-generator grunt-cli

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get update
sudo apt-get install -y mongodb-org
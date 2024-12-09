#!/bin/bash

apt-get update -y
apt-get install -y tmux vim stow
cd /home/ubuntu
git clone https://github.com/iypetrov/.vm-dotfiles.git
(cd .vm-dotfiles && stow .)
chown ubuntu:ubuntu /home/ubuntu/.tmux.conf
chown ubuntu:ubuntu /home/ubuntu/.vimrc

curl -fsSl https://get.docker.com | sh
groupadd docker
gpasswd -a ubuntu docker
docker swarm init

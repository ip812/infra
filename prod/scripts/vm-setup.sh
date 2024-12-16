#!/bin/bash

# SSH keys
echo ${admin_ssh_public_key} >> /home/ubuntu/.ssh/authorized_keys
echo ${deploy_ssh_public_key} >> /home/ubuntu/.ssh/authorized_keys

# Dependencies
apt-get update -y
apt-get install -y tmux vim

# dotfiles
cd /home/ubuntu
git clone https://github.com/iypetrov/.vm-dotfiles.git
chmod -R ugo+r /home/ubuntu/.vm-dotfiles
ln -s /home/ubuntu/.vm-dotfiles/.tmux.conf /home/ubuntu/.tmux.conf
ln -s /home/ubuntu/.vm-dotfiles/.vimrc /home/ubuntu/.vimrc
ln -s /home/ubuntu/.vm-dotfiles/.tmux.conf /root/.tmux.conf
ln -s /home/ubuntu/.vm-dotfiles/.vimrc /root/.vimrc

# Docker
curl -fsSl https://get.docker.com | sh
gpasswd -a ubuntu docker

# Swarm
docker swarm init
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token ${github_access_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/ip812/apps/actions/workflows/deploy.yml/dispatches \
  -d '{"ref": "main"}'

#!/bin/bash

echo ${admin_ssh_public_key} >> /home/ubuntu/.ssh/authorized_keys
echo ${deploy_ssh_public_key} >> /home/ubuntu/.ssh/authorized_keys

apt-get update -y
apt-get install -y tmux vim stow
cd /home/ubuntu
git clone https://github.com/iypetrov/.vm-dotfiles.git
(cd .vm-dotfiles && stow .)
chown ubuntu:ubuntu /home/ubuntu/.tmux.conf
chown ubuntu:ubuntu /home/ubuntu/.vimrc

curl -fsSl https://get.docker.com | sh
# groupadd docker
gpasswd -a ubuntu docker

docker swarm init
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token ${github_access_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/ip812/apps/actions/workflows/deploy.yml/dispatches \
  -d '{"ref": "main"}'

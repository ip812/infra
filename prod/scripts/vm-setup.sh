#!/bin/bash

# Dependencies
apt-get update -y
apt-get install -y tmux vim sqlite3

# Litestream
wget https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.deb
dpkg -i litestream-v0.3.13-linux-amd64.deb
rm litestream-v0.3.13-linux-amd64.deb

# Dotfiles
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

# Swarm init & secrets
docker swarm init
printf ${blog_domain} | docker secret create blog_domain -
printf ${blog_port} | docker secret create blog_port -
printf ${blog_db_file} | docker secret create blog_db_file -
printf ${blog_aws_region} | docker secret create blog_aws_region -
printf ${blog_aws_access_key_id} | docker secret create blog_aws_access_key_id -
printf ${blog_aws_secret_access_key} | docker secret create blog_aws_secret_access_key -

# Trigger deploy pipeline
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token ${github_access_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/ip812/apps/actions/workflows/deploy.yml/dispatches \
  -d '{"ref": "main"}'


#!/bin/bash

# Add Cloudflare's package signing key
mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add Cloudflare's apt repo to your apt repositories
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflared.list

# Dependencies
apt-get update -y
apt-get install -y tmux vim cloudflared

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

# Run cloudflare tunnel
while true; do cloudflared tunnel run --token ${ip812_tunnel_token}; done


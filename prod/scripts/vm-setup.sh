#!/bin/bash

# Dependencies
apt-get update -y
apt-get install -y tmux vim sqlite3 fzf

# Dotfiles
cd /home/ubuntu
git clone https://github.com/iypetrov/.vm-dotfiles.git
chmod -R ugo+r /home/ubuntu/.vm-dotfiles
ln -s /home/ubuntu/.vm-dotfiles/.tmux.conf /root/.tmux.conf
ln -s /home/ubuntu/.vm-dotfiles/.vimrc /root/.vimrc

brc=$(cat <<'EOF'
# Docker
alias d="docker"
alias dls="docker service ls"
alias mdls="watch -n 1 docker service ls"
alias dps="docker ps -a"
alias dlog="docker service logs -f"

db() {
    tmpfile=$(mktemp)

    find /var/lib/docker/volumes -maxdepth 3 -mindepth 3 -type f -name "*.db" | while IFS= read -r filepath; do
        basename=$(basename "$filepath")
        echo "$basename|$filepath" >> "$tmpfile"
    done

    selected=$(cut -d '|' -f 1 "$tmpfile" | fzf --prompt="Select a database file: ")
    if [[ -n "$selected" ]]; then
        selected_file=$(grep "^$selected|" "$tmpfile" | cut -d '|' -f 2)
        sqlite3 "$selected_file"
    else
        echo "No file selected."
    fi

    rm -f "$tmpfile"
}
EOF
)
echo "$brc" >> ~/.bashrc

# Litestream
lstream=$(cat <<EOF
dbs:
  - path: /path/to/your/database.db
    replicas:
      - type: s3
        bucket: your-s3-bucket
        path: /path/in/s3
        region: your-region
EOF
)
echo "$lstream" | tee /etc/litestream.yml > /dev/null

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


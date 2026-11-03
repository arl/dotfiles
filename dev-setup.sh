#!/usr/bin/env bash

# install go with goversion
goversion download go1.27.3

# install shfmt
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# must make idempotent
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xvf nvim-linux-x86_64.tar.gz
mv nvim-linux-x86_64 ~/.local/bin/
ln -s ~/.local/bin/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim

curl -L https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz | gunzip > ~/.local/bin/tree-sitter
chmod +x ~/.local/bin/tree-sitter


# install docker
sudo apt install docker.io docker-compose-v2 -y

sudo apt install xclip

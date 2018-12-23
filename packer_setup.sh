#!/bin/sh

# executes within the ephermeral instance used to generate the image from
echo "[-] Executing from within $PWD"

# bake my .bashrc iand .vimrc into the image as well because why not
VIMRC="https://raw.githubusercontent.com/kawing-ho/dotfiles/master/.vimrc"
BASH_ALIASES="https://raw.githubusercontent.com/kawing-ho/dotfiles/master/.bash_aliases"

wget -q "$VIMRC"
wget -q "$BASH_ALIASES"

# make sure vim is installed
which vim > /dev/null || apt-get install -y vim

# ============================
# install all the tools needed
# - docker
# - node
# - yarn
# - packer + terraform 
# ============================

# install docker
curl -fsSL https://get.docker.com | bash 

# install node
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
apt-get install -y nodejs

# install yarn
curl -o- -L https://yarnpkg.com/install.sh | bash
export PATH="$HOME/.yarn/bin:$PATH"

# install unzip
apt-get install -y zip

# install packer + terraform
wget -q -O /tmp/packer.zip "https://releases.hashicorp.com/packer/1.3.3/packer_1.3.3_linux_amd64.zip"
unzip /tmp/packer.zip -d /usr/local/bin

wget -q -O /tmp/terraform.zip "https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip"
unzip /tmp/terraform.zip -d /usr/local/bin


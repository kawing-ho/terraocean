#!/bin/sh

# executes within the ephermeral instance used to generate the image from
echo "[-] Executing from within $PWD"

# reduce noise on login
touch .hushlogin

# *.rc files will be pulled on provision time instead of baked in

# make sure vim is installed
which vim > /dev/null || apt-get install -y vim

# ============================
# install all the tools needed
# - docker
# - node
# - yarn
# - packer + terraform 
# ============================

# need to install unzip before Hashicorp stuff
apt-get install unzip

# install hub (token not baked in)
wget -q -O /tmp/hub.tgz "https://github.com/github/hub/releases/download/v2.7.0/hub-linux-amd64-2.7.0.tgz"
tar -xf /tmp/hub.tgz -C /tmp
bash /tmp/hub-linux-amd64-2.7.0/install

# install docker
curl -fsSL https://get.docker.com | bash 

# install node
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
apt-get install -y nodejs

# install yarn (it sets the path already)
curl -o- -L https://yarnpkg.com/install.sh | bash

# install gulp (build yarn from source)
npm install gulp-cli -g
npm install gulp -D
npx -p touch nodetouch gulpfile.js

# install packer + terraform
wget -q -O /tmp/packer.zip "https://releases.hashicorp.com/packer/1.3.3/packer_1.3.3_linux_amd64.zip"
unzip /tmp/packer.zip -d /usr/local/bin

wget -q -O /tmp/terraform.zip "https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip"
unzip /tmp/terraform.zip -d /usr/local/bin

# git clone repo and yarn repo
ssh-keyscan github.com >> ~/.ssh/known_hosts
[ -z "$REPO_URL" -o -z "$YARN_URL" ] && echo "[Repository URLs ENV vars not defined !!!]"
chmod 600 ~/.ssh/id_rsa*

# seems like it hangs here but its just taking its time
echo "These clones processes will take awhile ..."
git clone "$REPO_URL"
git clone "$YARN_URL"

# docker pull image 
[ -z "$IMAGE" ] && echo "[Docker container ENV var not defined !!!]"
docker pull "$IMAGE"

# install vim colors
mkdir ~/.vim
git clone https://github.com/flazz/vim-colorschemes.git ~/.vim

# remove repository SSH keys
rm -rf "$HOME/.ssh/*"

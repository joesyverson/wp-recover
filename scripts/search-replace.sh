#!/bin/bash

# apt update
# apt install -y gnupg wget lsb-release
# wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb
# dpkg -i mysql-apt-config*
# apt update
# apt install mysql-server

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# php wp-cli.phar --info
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
# wp --info
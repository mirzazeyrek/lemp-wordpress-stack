#!/bin/sh

# STILL ON PROGRESS
#
# WordPress Setup Script
#
# This script will install and configure WordPress on
# an Ubuntu 16.04 droplet
# Generate root and wordpress mysql passwords

export DEBIAN_FRONTEND=noninteractive;

#-- User Defined Variables --#
# hostname=''    #Your hostname (e.g. server.example.com)
# sudo_user=''    #Your username
# sudo_user_passwd=''     #your password
root_passwd='do1604nginx'    #Your new root password
pass_file='/root/mysql_passwd.txt'
# ssh_port='22'   #Your SSH port if you wish to change it from the default
#-- UDV End --#

#creating random passwords
create_passwords() {
pass_file = '/root/mysql_passwd.txt'
touch pass_file
root_mysql_passwd=`dd if=/dev/urandom bs=1 count=16 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;
wp_mysql_passwd=`dd if=/dev/urandom bs=1 count=8 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev | tr -dc 'a-zA-Z0-9'`;
echo "root mysql password: $root_mysql_passwd" >> pass_file
echo "wordpress password: $wp_mysql_passwd" >> pass_file
}

install_packages() {
    #uff8_fix
    install_php_7
    install_mysql_57
    install_nginx
    install_unzip
    restart_packages
    echo "Installation Done."
}

restart_packages() {
    echo "Restarting Nginx, PHP-FPM and MySQL."
    sleep 1
    sudo systemctl restart php7.0-fpm
    service nginx restart
    service mysql restart
    echo "Packages restarted."
}

uff8_fix() {
    # use this function if you have any utf-8 related error with ondrej/php ppa
    echo "Fixing utf-8 error for ondrej/php package."
    sleep 1
    apt-get install -y language-pack-en-base
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
}

general_update() {
    echo "Updating packages."
    sleep 1
    apt-get update
    apt-get -y upgrade
}

install_unzip() {
    echo "Install unzip"
    sleep 1
    apt-get -y install unzip
}

install_mysql_57() {
    echo "Installing MySQL 5.7 Server and Client"
    sleep 1
    apt-get -y install debconf-utils
    echo mysql-server mysql-server/root_password password $root_mysql_passwd | sudo debconf-set-selections
    echo mysql-server mysql-server/root_password_again password $root_mysql_passwd | sudo debconf-set-selections
    sudo apt-get -y install mysql-server mysql-client
    apt-get -y install mysql-server-5.7
}

install_nginx() {

    echo "Installing Nginx webserver"
    sleep 1
    echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/nginx-stable.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
    sudo apt-get update
    sudo apt-get -y install nginx
}

install_php_7() {
    echo "Adding ppa:ondrej/php repository as default PHP repository."
    sleep 1
    # -y flag means automatically say yes for command prompt.
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt-get update
    echo "Installing PHP 7.0 packages"
    sleep 1
    apt-get -y install screen build-essential libcurl3 libmcrypt4 libmemcached11 libxmlrpc-epi0 php7.0-cli php7.0-common php7.0-curl php7.0-fpm php7.0-gd php7.0-intl php7.0-json php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-readline php7.0-xml php7.0-xmlrpc psmisc libmcrypt-dev mcrypt php-pear php-mysql php-mbstring php-mcrypt php-xml php-intl libmhash2 php-common
}

set_packages()
{
    #updating packages again
    general_update
    get_wordpress
    set_mysql
    echo "Configure PHP settings"
    sleep 1
    # sed, a special editor for modifying files automatically. If you want to write a program to make changes in a file, sed is the tool to use.
    #" The -r Extended Regular Expression argument
    #
    # When I mention patterns, such as "s/pattern/", the pattern is a regular expression.
    # There are two common classes of regular expressions, the original "basic" expressions, and the "extended" regular
    # expressions. For more on the differences see My tutorial on regular expressions and the the section on extended
    # regular expressions. Because the meaning of certain characters are different between the regular
    # and extended expressions, you need a command line argument to enable sed to use the extension.
    # To enable this extension, use the "-r" command, as mentioned in the example on finding duplicated words on a line
    #
    # sed -r -n '/\([a-z]+\) \1/p'
    # or
    # sed --regular-extended -quiet '/\([a-z]+\) \1/p'
    #
    # I already mentioned that Mac OS X and FreeBSD uses -E instead of -r.
    #
    #   -i in-place argument.
    #
    # GNU Sed allows you to do this with a command line option - "-i". Let's assume that we are going to make the same
    # simple change - adding a tab before each line. This is a way to do this for all files in a directory with the ".txt"
    # extension in the current directory:
    #
    # sed -i 's/^/\t/' *.txt
    # The long argument name version is
    # sed --in-place 's/^/\t/' *.txt
    # This verison deletes the original file. If you are as cautious as I am, you may prefer to specify an extension,
    # which is used to keep a copy of the original:
    #
    # sed -i.tmp 's/^/\t/' *.txt"
    #
    # @source http://www.grymoire.com/Unix/Sed.html#uh-62h
    #
    # What this command does is increasing memory limit from 16M to 48M
    #sed -i -r 's/\s*memory_limit\s+=\s+16M/memory_limit = 48M/g' /etc/php5/cgi/php.ini

}

get_wordpress() {
    # Download and uncompress WordPress
    echo "Downloading & Unzipping WordPress Latest Release"
    sleep 1
    wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip;
    cd /tmp/ || exit;
    unzip /tmp/wordpress.zip;
}

set_mysql() {
    echo "Set up database user"
    sleep 1
    # Set up database user
    root_mysql_passwd=`sed -n "s/^.*root mysql password:\s*\(\S*\).*$/\1/p" $pass_file`;
    echo $root_mysql_passwd;
    echo sed -n "s/^.*root mysql password:\s*\(\S*\).*$/\1/p" $pass_file;
    wp_mysql_passwd=`sed -n "s/^.*wordpress password:\s*\(\S*\).*$/\1/p" $pass_file`;
    echo $wp_mysql_passwd;
    echo sed -n "s/^.*wordpress password:\s*\(\S*\).*$/\1/p" $pass_file;
    echo /usr/bin/mysqladmin -u root -h localhost create wordpress -p$root_mysql_passwd;
    echo /usr/bin/mysql -uroot -p$root_mysql_passwd -e "CREATE USER wordpress@localhost IDENTIFIED BY '"$wp_mysql_passwd"'";
    echo /usr/bin/mysql -uroot -p$root_mysql_passwd -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost";
}

set_php_7() {
    echo "set php 7"
    sleep 1
    # Configure PHP
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
    sed -i "s|listen = 127.0.0.1:9000|listen = /var/run/php5-fpm.sock|" /etc/php5/fpm/pool.d/www.conf;
    sudo service php5-fpm restart
}

#install_packages
#set_packages
set_mysql
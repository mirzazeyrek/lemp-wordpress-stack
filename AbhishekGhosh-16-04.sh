#!/bin/bash
#-- This file is a clone from https://github.com/AbhishekGhosh/Ubuntu-16.04-Nginx-WordPress-Autoinstall-Bash-Script
# Unfortunately the current version of this bash script is not working on DigitalOcean Droplet's due to several errors.
# Also has a customized mysql version which is called as percona MySQL
# --#

export DEBIAN_FRONTEND=noninteractive;

#-- User Defined Variables --#
# hostname=''    #Your hostname (e.g. server.example.com)
# sudo_user=''    #Your username
# sudo_user_passwd=''     #your password
# root_passwd=''    #Your new root password
# ssh_port='22'   #Your SSH port if you wish to change it from the default
#-- UDV End --#

install_pkg()
{
  echo "Updating packages."
  sleep 1
  aptitude update
  aptitude -y safe-upgrade
  aptitude -y full-upgrade
  echo "Adding ppa:ondrej/php repository as default PHP repository."
  sleep 1
  sudo add-apt-repository ppa:ondrej/php
  aptitude update
  aptitude -y safe-upgrade
  aptitude -y full-upgrade
  echo "Installing PHP 7.0 packages."
  sleep 1
  aptitude -y install screen build-essential libcurl3 libmcrypt4 libmemcached11 libxmlrpc-epi0 php7.0-cli php7.0-common php7.0-curl php7.0-fpm php7.0-gd php7.0-intl php7.0-json php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-readline php7.0-xml php7.0-xmlrpc psmisc libmcrypt-dev mcrypt php-pear php-mysql php-mbstring php-mcrypt php-xml php-intl libmhash2 php-common
  echo "Installing memcached (not php-memcached).Memchaed will be available at Port 11211 of IP 127.0.0.1 (localhost)."
  echo "Memchaed will be available at Port 11211 of IP 127.0.0.1 (localhost)."
  sleep 1
  aptitude -y install memcached
  echo "Adding cgi.fix_pathinfo=0 to php.ini"
  sleep 1
  echo "cgi.fix_pathinfo=0" >> /etc/php5/cgi/php.ini
  sleep 1
  echo "Setting up OpCache and PHP memory limit"
  sleep 1
  echo "opcache.memory_consumption=512" >> /etc/php/7.0/fpm/conf.d/10-opcache.ini
  echo "opcache.max_accelerated_files=50000" >> /etc/php/7.0/fpm/conf.d/10-opcache.ini
  echo "opcache.revalidate_freq=0" >> /etc/php/7.0/fpm/conf.d/10-opcache.ini
  echo "opcache.consistency_checks=1" >> /etc/php/7.0/fpm/conf.d/10-opcache.ini
  sed -i -r 's/\s*memory_limit\s+=\s+16M/memory_limit = 48M/g' /etc/php5/cgi/php.ini
  echo "Installing Percona MySQL 5.7 Server and Client"
  sleep 1
  gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
  gpg -a --export CD2EFD2A | apt-key add -
  sudo sh -c 'echo "deb http://repo.percona.com/apt xenial main" >> /etc/apt/sources.list.d/percona.list'
  aptitude update
  aptitude -y safe-upgrade
  aptitude -y full-upgrade
  aptitude -y install percona-server-5.7
  mysql_secure_installation
  echo "Installing Nginx-Extras webserver"
  sleep 1
  aptitude -y install nginx-extras
  echo "Restarting Nginx, PHP-FPM and MySQL."
  sudo systemctl restart php7.0-fpm
  service nginx restart
  service mysql restart
  echo "Done."
}

config_web()
{
  echo "Using custom nginx default site settings."
  echo " " >> /etc/nginx/sites-available/default
  cat tmp/default.nginx >> /etc/nginx/sites-available/default
  chmod +x /etc/nginx/thecustomizewindows/
  sudo chown -R root:www-data /usr/share/nginx/html
  echo "Saving default my.cnf as /etc/mysql/my.bak"
  sleep 1
  cp /etc/mysql/my.cnf /etc/mysql/my.bak
  echo " " >> /etc/mysql/my.cnf
  echo "Using custom my.cnf as temporary solution."
  echo "You should optimize the my.cnf later from percona.com's wizard or using Major Hayden's Script."
  echo "You will not see Error Connecting Database Error with our my.cnf"
  sleep 1
  cat tmp/my.cnf >> /etc/mysql/my.cnf
  echo "Restarting Nginx, PHP-FPM and MySQL."
  sudo systemctl restart php7.0-fpm
  service nginx restart
  service mysql restart
}

copy_site_setup_files()
{
  echo "A directory named thecustomizewindows will be created at /etc/nginx/ location."
  echo "You will need to the load scripts from /etc/nginx/thecustomizewindows location for W3 Total Cache."
  echo "If you rename that thecustomizewindows directory, adjust the new path via Nginx vHost file."
  echo "We used our domain name thecustomizewindows name to avoid confusing with your domain name later."
  echo "It has no other importance."
  sleep 1
  mkdir /etc/nginx/thecustomizewindows/
  cp files/w3tc.conf /etc/nginx/thecustomizewindows/w3tc.conf
}

create_site()
{
  local opt=""
    echo -n "Creating site on nginx..."
    cd /usr/share/nginx/html
    rm -r /usr/share/nginx/html/*
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzxf latest.tar.gz
    rm latest.tar.gz && cd wordpress
    mv * ..
    cd ..
    rm -r wordpress
    cp /usr/share/nginx/html/wp-config-sample.php /usr/share/nginx/html/wp-config.php
    rm /usr/share/nginx/html/wp-config-sample.php
    sudo chown -R root:www-data /usr/share/nginx/html
    sudo find /usr/share/nginx/html -type d -exec chmod g+s {} \;
    sudo chmod g+w /usr/share/nginx/html/wp-content
    sudo chmod -R g+w /usr/share/nginx/html/wp-content/themes
    sudo chmod -R g+w /usr/share/nginx/html/wp-content/plugins
    echo "done."
  fi
}

setup_wp()
{

PASS=`pwgen -s 40 1`
mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $1;
CREATE USER '$1'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo "MySQL user created."
echo "Username:   $1"
echo "Password:   $PASS"
}

print_report()
{
  echo "We are trying to autoinstall WordPress if it fails you need to manually work from Web GUI."
  sleep 1
  echo "Database to be used:   localhost"
  echo "Database user:   $1 (and also   root)"
  echo "Database user password:   $PASS for the user $1"
  sed -i "s/'DB_NAME', 'database_name_here'/'DB_NAME', '$1'/g" /usr/share/nginx/html/wp-config.php;
  sed -i "s/'DB_USER', 'username_here'/'DB_USER', '$1'/g" /usr/share/nginx/html/wp-config.php;
  sed -i "s/'DB_PASSWORD', 'password_here'/'DB_PASSWORD', '$PASS'/g" /usr/share/nginx/html/wp-config.php;
  sed -i "s/'DB_HOST', 'localhost'/'DB_HOST', 'localhost'/g" /usr/share/nginx/html/wp-config.php;
  echo "Visit your domain name or IP and use the information if needed."
}


cleanup()
{
  rm -rf tmp/*
}

#-- Function calls and flow of execution --#

# install packages
install_pkg

# configure nginx web server
config_web

# copy over site setup files
copy_site_setup_files

# create the site on nginx
create_site

# setup Wordpress
setup_wp

# print WP installation report
print_report

# clean up tmp
cleanup
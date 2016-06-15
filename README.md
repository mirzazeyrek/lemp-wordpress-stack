# LEMP WORDPRESS STACK
One click installation for latest wordpress and php 7.0 versions on ubuntu 16.04

This file is only tested on DigitalOcean. Please feel free to contribute on further development and please report issues.

Use this user script while creating the droplet:

```
#cloud-config
chpasswd:
  list: |
    root:yourrootpassword
  expire: False
runcmd:
- wget https://raw.githubusercontent.com/mirzazeyrek/lemp-wordpress-stack/master/lemp-wordpress-16-04.sh
- chmod +x lemp-wordpress-16-04.sh
- ./lemp-wordpress-16-04.sh
```

Your passwords will be stored in /root/mysql_passwd.txt

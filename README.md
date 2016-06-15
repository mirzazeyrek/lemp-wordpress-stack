# LEMP WORDPRESS STACK
One click installation for latest wordpress and php 7.0 versions on ubuntu 16.04

This file is only tested on DigitalOcean. Please feel free to contribute on further development and please report issues.

Use this user script while creating the droplet:

![image](https://cloud.githubusercontent.com/assets/6233650/16084574/04d43c8a-3322-11e6-81f1-a46e31f5728e.png) 

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

If you want to set different web site and subfolder for installation edit those lines:

```
    # leave sub_folder empty if you don't want to make installation to a sub_folder
    #sub_folder=""
    #web_address="localhost"
    # for making an installation to www.mywebsite.com/myblog/
    sub_folder="myblog"
    web_address="www.mywebsite.com"
```

Upload the edited file somewhere and use it for your installation:

```
#cloud-config
chpasswd:
  list: |
    root:yourrootpassword
  expire: False
runcmd:
- wget https://yourwebsite.com/edited-lemp-wordpress-16-04.sh
- chmod +x edited-lemp-wordpress-16-04.sh
- ./edited-lemp-wordpress-16-04.sh
``` 


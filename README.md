# LEMP WORDPRESS STACK
One step installation for latest wordpress and php 7.1 versions on ubuntu 16.04.

This file is tested on DigitalOcean & Linode. Please feel free to contribute on further development and please report issues.

# MANUAL INSTALLATION

Login as root:

```
    wget https://raw.githubusercontent.com/mirzazeyrek/lemp-wordpress-stack/master/lemp-wordpress-16-04.sh
    bash lemp-wordpress-16-04.sh
```

# DIGITALOCEAN INSTALLATION
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

Upload the edited file somewhere and use it for your installation and please make sure you have set the correct settings for the file:

1- Unix line endings.

2- UTF-8 WITHOUT BOM.

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


#!/bin/bash -e
#
# user_data_wp.sh
#

# The following variables must be set:
# * DB_NAME
# * DB_USERNAME
# * DB_PASSWORD
# * DB_HOST
# * EFS_ID

# Install software packages
dnf update -y
dnf install -y wget httpd
dnf install -y php php8.4-gd php-mysqli mariadb1011     # gd is needed for image manipulation
dnf install -y amazon-cloudwatch-agent collectd
dnf install -y amazon-efs-utils

# Enable and start httpd and mariadb
systemctl enable httpd
systemctl start httpd

# Install WordPress
wget http://wordpress.org/latest.tar.gz -P /tmp
cd /var/www/html
tar -zxvf /tmp/latest.tar.gz --strip-component=1

# Configure Wordpress
cp wp-config-sample.php wp-config.php
sed -i "s/'database_name_here'/'${DB_NAME}'/g" wp-config.php
sed -i "s/'username_here'/'${DB_USERNAME}'/g" wp-config.php
sed -i "s/'password_here'/'${DB_PASSWORD}'/g" wp-config.php
sed -i "s/'localhost'/'${DB_HOST}'/g" wp-config.php

# Make a copy of /var/www/html/wp-content
rm -rf /tmp/wp-content
cp -a /var/www/html/wp-content /tmp

# Mount the EFS file system for WordPress content
mkdir -p /var/www/html/wp-content
echo -e "${EFS_ID}:/ /var/www/html/wp-content efs _netdev,tls,iam 0 0" >> /etc/fstab
mount -a -t efs defaults

# Restore wp-contents if required
if [ ! -d /var/www/html/wp-content/themes ]; then
    cp -a /tmp/wp-content/* /var/www/html/wp-content
fi
rm -rf /tmp/wp-content

# Change ownership
chown -R apache:apache /var/www/html

# Download and install wp-cli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp
mv /tmp/wp-cli.phar /usr/local/bin/wp
chmod a+x /usr/local/bin/wp


# Resolve SELinux permission issues
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g"
chcon -R -t httpd_sys_rw_content_t /var/www/html/*
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/*"
restorecon -Rv /var/www/html/*

# Start the CloudWatch Agent using configuration stored in SSM Parameter AmazonCloudWatch-linux
chmod a+x /var/log/httpd
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:AmazonCloudWatch-linux

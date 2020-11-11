#!/bin/bash
HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/hostname)

sudo apt update
sudo apt install nginx -y
sudo sed -i "s/nginx/OpsSchool Rules userHostName: $HOSTNAME/g" /var/www/html/index.nginx-debian.html
sudo sed -i '15,23d' /var/www/html/index.nginx-debian.html
service nginx restart

sudo apt install awscli -y
crontab -l | { cat; echo "0 * * * * aws s3 cp /var/log/nginx/access.log s3://web-log-by-biata"; } | crontab -


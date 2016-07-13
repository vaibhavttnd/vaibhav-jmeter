#!/bin/bash

######## PASSED AS USER DATA TO JENKINS SERVER TO INSTALL JENKINS AND NGINX

sudo apt-get update
sudo apt-get install openjdk-7-jdk --fix-missing -yy

#install jenkins
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins -y

#check if jenkins is installed
if [ $? -eq 0 ]
then
	echo "Jenkins installed"
else
	echo "Jenkins installation failed"
fi

#add jenkins user to sudo group
sudo usermod -a -G sudo jenkins

sudo apt-get install git -y
sudo apt-get install awscli -y
sudo apt-get install nginx -y

#set proxy-pass
cat <<here > /etc/nginx/sites-enabled/default
server {
        listen 80 default_server;
        root /usr/share/nginx/html;
        index index.html index.htm;
        server_name localhost;
        location / {
            proxy_pass http://localhost:8080;
 }}
here
sudo nginx -t
if [ $? -eq 0 ]
then
	sudo service nginx restart
else 
	echo "Nginx failed"
fi
sudo mkdir /var/lib/jenkins/.aws/
cat <<here >> /var/lib/jenkins/.aws/config
[default]
region=us-east-1
output=json
here

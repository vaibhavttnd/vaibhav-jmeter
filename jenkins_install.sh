#!/bin/bash

wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins -y

if [ $? -eq 0 ]
then
	echo "Jenkins installed"
else
	echo "Jenkins installation failed"
fi

sudo usermod -a -G sudo jenkins
sudo chown jenkins:jenkins /usr/share/jmeter/extras

#!/bin/bash

touch /tmp/install.log
> /tmp/install.log

wget https://s3.amazonaws.com/$BUCKET/jenkins_install.sh -O tmp/jenkins_install.sh
wget https://s3.amazonaws.com/$BUCKET/jmeter_master.sh -O /tmp/jmeter_master.sh

sudo bash /tmp/jmeter_master.sh >> /tmp/install.log
sudo bash /tmp/jenkins_install.sh >> /tmp/install.log
sudo apt-get install git -y

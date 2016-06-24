#!/bin/bash
PROJECT=GunjanLatest;BUCKET=LoadTesting_GunjanLatest
set -e

sudo apt-get update
sudo apt-get install openjdk-7-jdk --fix-missing -yy

#install jmeter and ant
sudo apt-get install jmeter -y
sudo apt-get install ant -y

#remove loopback address from jmeter.properties
sudo sed -i 's/remote_hosts=127/#remote_hosts=127/' /usr/share/jmeter/bin/jmeter.properties

mkdir /usr/share/jmeter/extras

#wget https://s3.amazonaws.com/$BUCKET/conversion.xml -O /usr/share/jmeter/extras/conversion.xml
#wget https://s3.amazonaws.com/$BUCKET/jmeter-results-detail-report_21.xsl -O /usr/share/jmeter/extras/jmeter-results-detail-report_21.xsl

  

#!/bin/bash
set -e

############### PASSED AS USER DATA TO JMETER SLAVE SERVERS TO INSTALL AND LAUNCH JMETER

sudo apt-get update
sudo apt-get install openjdk-7-jdk --fix-missing -yy

sudo apt-get install jmeter -y

#remove loopback address from jmeter.properties
sudo sed -i 's/remote_hosts=127/#remote_hosts=127/' /usr/share/jmeter/bin/jmeter.properties

#pass the ip of this slave as hostname and launch jmeter-server script
ip=$(ec2metadata | grep -m 1 public-ipv4 | awk '{print $2}')
/usr/share/jmeter/bin/jmeter-server -Djava.rmi.server.hostname=$ip

#!/bin/bash
set -e

############### PASSED AS USER DATA TO JMETER SLAVE SERVERS TO INSTALL AND LAUNCH JMETER

sudo apt-get update
sudo apt-get install openjdk-7-jdk --fix-missing -yy

sudo apt-get install jmeter -y

#remove loopback address from jmeter.properties
sudo sed -i 's/remote_hosts=127/#remote_hosts=127/' /usr/share/jmeter/bin/jmeter.properties

# calculate 80% of memory and alot it to heap
TOTALMEM=`grep MemTotal /proc/meminfo | tr -s ' ' ' ' | cut -d' ' -f2 `
MEM20=$(( (TOTALMEM/1024) * 20/100 ))
MEM80=$(( (TOTALMEM/1024) * 80/100 ))

sudo sed -i "s/run_java.*-Djmeter.home/run_java -Xms${MEM20}m -Xmx${MEM80}m -XX:NewSize=128m -XX:MaxNewSize=128m -XX:+UseG1GC -Djmeter.home/" /usr/share/jmeter/bin/jmeter


#pass the ip of this slave as hostname and launch jmeter-server script
ip=$(ec2metadata | grep -m 1 public-ipv4 | awk '{print $2}')
/usr/share/jmeter/bin/jmeter-server -Djava.rmi.server.hostname=$ip

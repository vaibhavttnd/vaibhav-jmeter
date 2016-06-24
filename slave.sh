#!/bin/bash
set -e
echo "slave.sh"
touch /usr/share/jmeter/extras/ip.txt
> /usr/share/jmeter/extras/ip.txt
#count=$NoOfInstances
count="1"
while [ $count > 0 ]
do
InstanceID=$(aws ec2 run-instances --image-id $AMI --key-name $KeyPairName --security-group-ids $SecurityGroup --instance-type $InstanceType --subnet $Subnet --associate-public-ip-address --user-data file:///usr/share/jmeter/extras/configScriptSlave --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
sleep 20
echo -ne `aws ec2 describe-instances --instance-id $InstanceID --output json | grep "PublicIpAddress" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g'` >> /usr/share/jmeter/extras/ip.txt
echo -ne "," >> /usr/share/jmeter/extras/ip.txt
sleep 20
count=`expr $count - 1`
done

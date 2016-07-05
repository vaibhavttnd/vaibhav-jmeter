#!/bin/bash
set -e
<<<<<<< HEAD
source instanceproperties.sh
source testproperties.sh

users=$1

echo "---------------------------------------------------Creating Slaves!-------------------------------------------------------------------"
sleep 5

####calculate no of slaves needed
num=`expr $users + $Load - 1`
SlavesNeeded=`expr $num / $Load`

> ./ip.txt
> ./RunningInstances.txt
`aws ec2 describe-instances --filters "Name=tag:Name,Values=Slave_$PROJECT" --output json | grep PublicIpAddress | cut -d\" -f4` > RunningInstances.txt
Running=`wc -l RunningInstances.txt`
if [ $Running -gt 0 ]
then
	cat RunningInstances.txt | while read LINE
	do
		echo $LINE"," > ip.txt
	done
fi

count=`expr $SlavesNeeded - $Running`

while [ $count > 0 ]
do
InstanceID=$(aws ec2 run-instances --image-id $AMI --key-name $KeyPairName --security-group-ids $SecurityGroup --instance-type $InstanceType --subnet $Subnet --associate-public-ip-address --user-data file://configScriptSlave --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
sleep 20
aws ec2 create-tags --resource $InstanceID --tags Key=Name,Value=Slave_$PROJECT
echo -ne `aws ec2 describe-instances --instance-id $InstanceID --output json | grep "PublicIpAddress" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g'` >> ip.txt
echo -ne "," >> ip.txt
count=`expr $count - 1`
done
echo "---------------------------------------------------Wait while slaves are configured!-----------------------------------------------------------"
sleep 300
echo "---------------------------------------------------Slaves are running!----------------------------------------------------"
=======
echo "slave.sh"
touch /usr/share/jmeter/extras/ip.txt
> /usr/share/jmeter/extras/ip.txt
source properties.sh
count=$NoOfInstances
while [ $count > 0 ]
do
InstanceID=$(aws ec2 run-instances --image-id $AMI --key-name $KeyPairName --security-group-ids $SecurityGroup --instance-type $InstanceType --subnet $Subnet --associate-public-ip-address --user-data file:///usr/share/jmeter/extras/configScriptSlave --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
sleep 20
aws ec2 create-tags --resource $InstanceID --tags Key=Name,Value=Slave_$count_$PROJECT
echo -ne `aws ec2 describe-instances --instance-id $InstanceID --output json | grep "PublicIpAddress" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g'` >> /usr/share/jmeter/extras/ip.txt
echo -ne "," >> /usr/share/jmeter/extras/ip.txt
sleep 20
count=`expr $count - 1`
done
>>>>>>> 4a989098bd3f26709e2a6ee8e1f880ed6467e329

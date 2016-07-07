#!/bin/bash
set -e
source instanceproperties.sh
source testproperties.sh

users=$1

echo "---------------------------------------------------Creating Slaves!-------------------------------------------------------------------"
sleep 5

####calculate no of slaves needed
num=`expr $users + $Load - 1`
SlavesNeeded=`expr $num / $Load`
sed -i '/export SlavesNeeded=/d' testproperties.sh
cat<<here >> testproperties.sh
export SlavesNeeded=$SlavesNeeded
here

> ./ip.txt
> ./RunningInstances.txt
echo `aws ec2 describe-instances --filters "Name=tag:Name,Values=Slave_$PROJECT" --output json | grep PublicIpAddress | cut -d\" -f4` > RunningInstances.txt
Running=`cat RunningInstances.txt | wc -l`
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

#!/bin/bash
set -e

source properties.sh

echo -n "Enter AMI ID: "
read AMI
#AMI=ami-fce3c696
echo -n "Enter Instance Type: "
read InstanceType
#InstanceType=t2.micro
echo -n "Enter Subnet-ID: "
read Subnet
#Subnet=subnet-a28a3dfa
echo -n "Enter Security Group ID: "
read SecurityGroup
#SecurityGroup=sg-ee751395
echo -n "Enter Name of Key Pair: "
read KeyPairName
#KeyPairName=key_Gunjan

sudo wget https://s3.amazonaws.com/$BUCKET/user_data_file.sh -O /tmp/user_data_file.sh

InstanceID=$(aws ec2 run-instances --image-id $AMI --key-name $KeyPairName --security-group-ids $SecurityGroup --instance-type $InstanceType --user-data file:///tmp/user_data_file.sh --subnet $Subnet --associate-public-ip-address --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
sleep 10
echo "Master created, Instance id= "$InstanceID
echo "Master IP= "$(aws ec2 describe-instances --instance-id $InstanceID --output json | grep "PublicIpAddress" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
aws ec2 create-tags --resource $InstanceID --tags Key=Name,Value=Master_$PROJECT
echo "Wait while Master Instance is configured"
sleep 300
echo "Done!"

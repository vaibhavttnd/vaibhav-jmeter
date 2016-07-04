#!/bin/bash

source instanceproperties.sh

echo -n "Enter AMI ID: "
read AMI
echo -n "Enter Instance Type: "
read InstanceType
echo -n "Enter URL of the Git Repository: "
read URL

cat <<here >> instanceproperties.sh
export AMI=$AMI
export InstanceType=$InstanceType
export URL=$URL
here

#git add instanceproperties.sh
#git commit -m "instanceproperties.sh"
#git push $URL

aws iam create-role --role-name LoadTesting-Role --assume-role-policy-document file://LoadTesting-Trust.json
aws iam put-role-policy --role-name LoadTesting-Role --policy-name LoadTesting-Permissions --policy-document file://LoadTesting-Permissions.json
aws iam create-instance-profile --instance-profile-name LoadTesting-Instance-Profile
aws iam add-role-to-instance-profile --instance-profile-name LoadTesting-Instance-Profile --role-name LoadTesting-Role
sleep 10

InstanceID=$(aws ec2 run-instances --image-id $AMI --iam-instance-profile Name=LoadTesting-Instance-Profile --key-name $KeyPairName --security-group-ids $SecurityGroup --instance-type $InstanceType --user-data file://jenkins_install.sh --subnet $Subnet --associate-public-ip-address --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
sleep 10

echo "Jenkins Master created, Instance id= "$InstanceID
echo "Master IP= "$(aws ec2 describe-instances --instance-id $InstanceID --output json | grep "PublicIpAddress" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
aws ec2 create-tags --resource $InstanceID --tags Key=Name,Value=Master_Jenkins_$PROJECT
echo "Wait while Jenkins Master Instance is configured"
sleep 300
echo "Done!"


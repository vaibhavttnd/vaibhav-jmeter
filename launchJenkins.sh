#!/bin/bash

############# TO LAUNCH JENKINS MASTER SERVER AND DISPLAY IP AND ADMIN PASSWORD

source EC2instanceproperties.sh
PassiveInstanceType=t2.nano


echo -n "Enter AMI ID: "
read AMI
echo -n "Enter Instance Type: "
read InstanceType
echo -n "Enter URL of the Git Repository: "
read URL

#write variables
cat <<here >> EC2instanceproperties.sh
export AMI=$AMI
export InstanceType=$InstanceType
export PassiveInstanceType=$PassiveInstanceType
export URL=$URL
here

#push to git
git add EC2instanceproperties.sh configJMeterMaster.sh
git commit -m "EC2instanceproperties.sh"
git push $URL

#create new role and instance profile
aws iam create-role --role-name LoadTesting-Role --assume-role-policy-document file://LoadTesting-Trust.json
aws iam put-role-policy --role-name LoadTesting-Role --policy-name LoadTesting-Permissions --policy-document file://LoadTesting-Permissions.json
aws iam create-instance-profile --instance-profile-name LoadTesting-Instance-Profile
aws iam add-role-to-instance-profile --instance-profile-name LoadTesting-Instance-Profile --role-name LoadTesting-Role
sleep 10

#launch instance
InstanceID=$(aws ec2 run-instances --image-id $AMI --iam-instance-profile Name=LoadTesting-Instance-Profile --key-name $KeyPairName --security-group-ids $SecurityGroup --instance-type $PassiveInstanceType --user-data file://configJenkinsMaster.sh --subnet $Subnet --associate-public-ip-address --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
sleep 10
echo "Jenkins Master created, Instance id= "$InstanceID

#find public ip of instance
MasterIP=$(aws ec2 describe-instances --instance-id $InstanceID --output json | grep "PublicIpAddress" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
echo "Master IP= "$MasterIP

aws ec2 create-tags --resource $InstanceID --tags Key=Name,Value=Master_Jenkins_$PROJECT
echo "Wait while Jenkins Master Instance is configured"
sleep 300

#extract admin password
echo -ne "Your Jenkins Administrator Password is: "
sudo ssh -i $KeyPairName.pem -o "StrictHostKeyChecking no" ubuntu@$MasterIP -t "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "Done!"


#/bin/bash

###########TO LAUNCH JMETER MASTER INSTANCE AND SSH INTO IT TO RUN JMETER TESTS

source EC2instanceproperties.sh
source JMetertestproperties.sh

echo "------------------Creating JMETER Master-----------------------------"
>$JMeterKey.pem
## create key pair for JMeter Master
aws ec2 create-key-pair --key-name $JMeterKey --query 'KeyMaterial' --output text > $JMeterKey.pem

sleep 10
InstanceID=$(aws ec2 run-instances --image-id $AMI --iam-instance-profile Name=LoadTesting-Instance-Profile --key-name $JMeterKey --security-group-ids $DefaultSecurityGroup $SecurityGroup --instance-type $PassiveInstanceType --user-data file://configJMeterMaster.sh --subnet $Subnet --associate-public-ip-address --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')

sleep 10

echo "JMETER Master created, Instance id= "$InstanceID

# Extracting public IP of jmeter master
MasterIP_Public=$(aws ec2 describe-instances --instance-id $InstanceID --output json | grep "PublicIpAddress" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')

# Extracting private IP of jmeter master 
MasterIP=$(aws ec2 describe-instances --instance-id $InstanceID --output json  | grep "PrivateIpAddress" | head -1 |  awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')

aws ec2 create-tags --resource $InstanceID --tags Key=Name,Value=Master_$PROJECT
echo "Master IP= "$MasterIP_Public
echo "Wait while Master Instance is configured"
sleep 300
echo "Done!"


########### ssh into master
echo "About to run tests!"
chmod 400 $JMeterKey.pem
ssh -i $JMeterKey.pem -o "StrictHostKeyChecking no" ubuntu@$MasterIP -t "sudo bash -x /usr/share/jmeter/extras/JMeterMasterRunTest.sh"

#terminate jmeter master instance
#aws ec2 terminate-instances --instance-ids $InstanceID

echo "End of tests!"

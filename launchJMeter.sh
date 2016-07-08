#/bin/bash
source instanceproperties.sh
source testproperties.sh

echo "------------------Creating JMETER Master-----------------------------"

## create key pair for JMeter Master
aws ec2 create-key-pair --key-name JMeterKey --output text | cut -d- -f2-8 > JMeterKey.pem

InstanceID=$(aws ec2 run-instances --image-id $AMI --iam-instance-profile Name=LoadTesting-Instance-Profile --key-name JMeterkey --security-group-ids $SecurityGroup --instance-type $InstanceType --user-data file://configScriptMaster.sh --subnet $Subnet --associate-public-ip-address --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')

sleep 10

echo "JMETER Master created, Instance id= "$InstanceID
MasterIP=$(aws ec2 describe-instances --instance-id $InstanceID --output json | grep "PublicIpAddress" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
aws ec2 create-tags --resource $InstanceID --tags Key=Name,Value=Master_$PROJECT
echo "Master IP= "$MasterIP
echo "Wait while Master Instance is configured"
sleep 300
echo "Done!"


########### ssh into master
echo "About to run tests!"
ssh -i ./$JMeterKey.pem ubuntu@$MasterIP -t "bash -x /usr/share/jmeter/extras/jmeter_master.sh"


######display that tests are done

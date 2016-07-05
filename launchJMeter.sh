#/bin/bash
source instanceproperties.sh
source testproperties.sh

#>slave.log

#IFS=','
#array=( $users )
#for i in ${array[@]}
#do

#bash -x slave.sh $i >> slave.log 2>&1


#>/tmp/jmeter_master.sh
#wget https://s3.amazonaws.com/$BUCKET_INSTALL/jmeter_master.sh -O /tmp/jmeter_master.sh

####send slave ips to jmeter_master.sh
#IPList=$(cat ip.txt |awk 'FNR==1{print $0}')
#sed -i '/IPList=/d' jmeter_master.sh
#sed -i "/#!\/bin\/bash/a IPList=$IPList; i=$i; users=$users; BUCKET_INSTALL=$BUCKET_INSTALL; BUCKET_RESULT=$BUCKET_RESULT; OutputFile=$OutputFile;" jmeter_master.sh


echo "------------------Creating JMETER Master-----------------------------"
InstanceID=$(aws ec2 run-instances --image-id $AMI --iam-instance-profile Name=LoadTesting-Instance-Profile --key-name $KeyPairName --security-group-ids $SecurityGroup --instance-type $InstanceType --user-data file://jmeter_master.sh --subnet $Subnet --associate-public-ip-address --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')

sleep 10

echo "JMETER Master created, Instance id= "$InstanceID
#echo "Master IP= "$(aws ec2 describe-instances --instance-id $InstanceID --output json | grep "PublicIpAddress" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
aws ec2 create-tags --resource $InstanceID --tags Key=Name,Value=Master_$PROJECT
echo "Wait while Master Instance is configured"
sleep 300
echo "Done!"


######display that tests are done

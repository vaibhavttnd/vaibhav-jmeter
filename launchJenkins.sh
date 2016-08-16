#!/bin/bash

############# TO LAUNCH JENKINS MASTER SERVER AND DISPLAY IP AND ADMIN PASSWORD

source EC2instanceproperties.sh
source validator.sh --source-only

# Set PassiveInstanceType to the type of instance of Jenkins and JMeter-Master.
PassiveInstanceType=t2.micro


while true; do 
	echo -n "Enter AMI ID: "
	read AMI
	
	if `validateInput "." $AMI`; then
		if `aws ec2 describe-images --image-ids ${AMI} 2>/dev/null 1>/dev/null`; then
			break
		fi
	else
		echo "Input seems inaccurate, please check."
	fi
done

while true; do 
	echo -n "Enter Instance Type: "
	read InstanceType
	
	if `validateInput "." $`; then
		# creating a temp file for exit status storage
		TEMP_EXIT_STATUS_FILE="/tmp/aws_temp_exit_status_file"
		TEMP_COMMAND_OUTPUT_FILE="/tmp/aws_temp_command_output_file"
		> ${TEMP_EXIT_STATUS_FILE}
		> ${TEMP_COMMAND_OUTPUT_FILE}
		# validating the input instance by running the command in backgroung
		# and then checking the exit status of command 

		# creating command before inserting into bash sub shell, because subshell doesnt support path expansion.
		COMMAND="aws ec2 describe-reserved-instances-offerings --instance-type ${InstanceType} --region ${Region}  > ${TEMP_COMMAND_OUTPUT_FILE} 2>&1 ; echo \$? > ${TEMP_EXIT_STATUS_FILE}"

		bash -c  "($COMMAND)" & 
		
		echo -ne "Validating instance type"
		while [[ ! -s ${TEMP_EXIT_STATUS_FILE} ]]; do
			echo -ne "."; sleep 0.5;
		done

		if [[ `cat ${TEMP_EXIT_STATUS_FILE}` == 0  ]]; then
			echo 'OK'
			break
		else
			echo 'FAIL'
			cat ${TEMP_COMMAND_OUTPUT_FILE}
		fi

		rm ${TEMP_EXIT_STATUS_FILE}
		rm ${TEMP_COMMAND_OUTPUT_FILE}
	else
		echo "Input seems inaccurate, please check."
	fi
done


while true; do 
	echo -n "Enter URL of the Git Repository: "
	read URL
	if `validateInput "." $URL`; then
		
		#use git ls-remote to validate the url
		IS_OKAY=0
		git ls-remote $URL && IS_OKAY=1

		if [[ ${IS_OKAY} -eq 1 ]]; then
			break
		fi
	else
		echo "Input seems inaccurate, please check."
	fi
done


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

while true; do
	IS_OKAY=0
	git push $URL && IS_OKAY=1
	if [[ $IS_OKAY -eq 1 ]]; then
		break
	fi
done

#create new role and instance profile
aws iam create-role --role-name LoadTesting-Role --assume-role-policy-document file://LoadTesting-Trust.json
aws iam put-role-policy --role-name LoadTesting-Role --policy-name LoadTesting-Permissions --policy-document file://LoadTesting-Permissions.json
aws iam create-instance-profile --instance-profile-name LoadTesting-Instance-Profile
aws iam add-role-to-instance-profile --instance-profile-name LoadTesting-Instance-Profile --role-name LoadTesting-Role
sleep 10

#launch instance
InstanceID=$(aws ec2 run-instances --image-id $AMI --iam-instance-profile Name=LoadTesting-Instance-Profile --key-name $KeyPairName --security-group-ids $DefaultSecurityGroup $SecurityGroup --instance-type $PassiveInstanceType --user-data file://configJenkinsMaster.sh --subnet $Subnet --associate-public-ip-address --output json | grep "InstanceId" | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')
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


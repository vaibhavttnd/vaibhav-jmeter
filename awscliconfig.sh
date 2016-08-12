#!/bin/bash
##### INSTALLS AND CONFIGURES AWS CLI ON THE LOCAL SYSTEM

#install awscli

source validator.sh --source-only


# check the modified date of /var/lib/apt/lists/partial/ and if it is more than 3 days old then perform update else prompt the user that update was performed less than 3 days from now, does he still want to perform update

# TODO: If /var/lib/apt/lists/partial/ doesnt exist, straight away perform update

FILE_TO_MONITOR="/var/lib/apt/lists/partial"
# threshold is 2 days (in seconds)
THRESHOLD_TIME=172800
			
if [ -a  "$FILE_TO_MONITOR" ];
	then
	# file exists
	# check the last modified

	FILE_MODIFIED_TIME=`stat --format=%Y $FILE_TO_MONITOR`
	CURRENT_TIME=`date +'%s'`

	if [ $((CURRENT_TIME-FILE_MODIFIED_TIME)) -le $THRESHOLD_TIME ];
	then
		# update was performed less than or eq 48 hours 
		# Prompt for action with blank as NO (do not update)

		while true;
		do
			echo -ne "Apt cache was updated less than $((THRESHOLD_TIME / (60*60))) hours ago, want to update n/y [no]: "
			read USER_INPUT
			: ${USER_INPUT:=no}

			if [ "$USER_INPUT" == "yes" ] || [ "$USER_INPUT" == "y"   ];
			then				sudo apt-get update
				sudo apt-get install python-pip -y; sudo pip install --upgrade awscli;
				break

			elif [ "$USER_INPUT" == "no" ] || [ "$USER_INPUT" == "n" ]
			then
				break

			fi
		done

	else
		# perform update
		sudo apt-get update
		sudo apt-get install python-pip -y; sudo pip install --upgrade awscli;
	fi

else
	# file doesnt exist
	# perform update 
	sudo apt-get update
	sudo apt-get install python-pip -y; sudo pip install --upgrade awscli;
fi

# Uncommenting old code
#sudo apt-get update
#sudo apt-get install python-pip -y; sudo pip install --upgrade awscli;

#check if aws cli has been successfully installed
if [ `which aws` ]
then
echo "AWS CLI installed"
else
echo "AWS CLI not installed"
fi

#configure awscli
while true;
do
	echo -n "Enter Profile (leave empty for 'default'): "
	read Profile
	: ${Profile:=default}

	while true; do
		echo -n "Enter Access key: "
		read AK

		if `validateInput "." "$AK" `;
			then
			break

		else
			echo "Input seems inaccurate, please check."
		fi
	done

	while true; do 
		echo -n "Enter Secret Access Key: "
		read SAK

		if `validateInput "." "$SAK"`; then
			break
		else
			echo "Input seems inaccurate, please check."
		fi
	done


	while true; do 
		echo -n "Enter region: "
		read Region
		
		if `validateInput "." "$Region"`; then
			break
		else
			echo "Input seems inaccurate, please check."
		fi
	done


	while true; do 
		echo -n "Enter output type (text/json): "
		read Output
		
		if `validateInput "^text$|^json$" "$Output"`; then
			break
		else
			echo "Input seems inaccurate, please check."
		fi
	done


	#create a config file
	mkdir -p ~/.aws/ && touch ~/.aws/config

cat <<here > ~/.aws/config
[${Profile}]
aws_access_key_id=$AK
aws_secret_access_key=$SAK
region=$Region
output=$Output
here


	# Make a test connection via aws cli 
	# if the test fails, get the details again
	echo -ne 'Testing AWS cli connection'

	DRY_RUN_TEMP_FILE="/tmp/aws_cli_dry_run"
	aws ec2 describe-instances --dry-run  1>${DRY_RUN_TEMP_FILE} 2>&1 &  #| grep 'Request would have succeeded'  & 
	MYPID=$! 

	while [[ `ps -p $MYPID -o comm=` == 'aws'   ]];  do	#
		echo -ne '.' 
		sleep 0.5 
	done

	 
	if `grep "Request would have succeeded" ${DRY_RUN_TEMP_FILE} 2>/dev/null 1>/dev/null`; then
		echo 'Authentication successful'
		# break from master loop
		break
	else
		
		echo 'Authentication unsuccessful'
	fi

	rm ${DRY_RUN_TEMP_FILE}
done


#edit file to configure Jenkins Server
sed -i '/\/var\/lib\/jenkins\/.aws\/config/Q' configJenkinsMaster.sh
cat <<here1 >> configJenkinsMaster.sh
cat <<here >> /var/lib/jenkins/.aws/config
[default]
region=$Region
output=$Output
here
here1

#pass variables to JMeter Master Server
sed -i '/Region=/d' configJMeterMaster.sh
sed -i "/#!\/bin\/bash/a Region=$Region;Output=$Output;" configJMeterMaster.sh

#write to EC2instanceproperties.sh
cat <<here >> EC2instanceproperties.sh
export Region=$Region
export Output=$Output
here

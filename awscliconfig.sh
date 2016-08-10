#!/bin/bash
##### INSTALLS AND CONFIGURES AWS CLI ON THE LOCAL SYSTEM

#install awscli

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
echo -n "Enter Profile (leave empty for 'default'): "
read Profile
: ${Profile:=default}
echo -n "Enter Access key: "
read AK
echo -n "Enter Secret Access Key: "
read SAK
echo -n "Enter region: "
read Region
echo -n "Enter output type (text/json): "
read Output

#create a config file
mkdir ~/.aws/ && touch ~/.aws/config

cat <<here > ~/.aws/config
[${Profile}]
aws_access_key_id=$AK
aws_secret_access_key=$SAK
region=$Region
output=$Output
here

#declare environment variables
#export AWS_ACCESS_KEY_ID=$AK
#export AWS_SECRET_ACCESS_KEY=$SAK
#export AWS_CONFIG_FILE="~/.aws/config"

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

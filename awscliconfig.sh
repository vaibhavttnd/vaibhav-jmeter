#!/bin/bash
##### INSTALLS AND CONFIGURES AWS CLI ON THE LOCAL SYSTEM

#install awscli
sudo apt-get update
sudo apt-get install awscli -y

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
region=$Region
output=$Output
here

#declare environment variables
export AWS_ACCESS_KEY_ID=$AK
export AWS_SECRET_ACCESS_KEY=$SAK
export AWS_CONFIG_FILE="~/.aws/config"

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

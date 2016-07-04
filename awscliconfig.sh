#!/bin/bash

#install awscli
sudo apt-get update
sudo apt-get install awscli -y

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

mkdir ~/.aws/ && touch ~/.aws/config

cat <<here > ~/.aws/config
[${Profile}]
region=$Region
output=$Output
here

export AWS_ACCESS_KEY_ID=$AK
export AWS_SECRET_ACCESS_KEY=$SAK
export AWS_CONFIG_FILE="~/.aws/config"

sed -i '/\/var\/lib\/jenkins\/.aws\/config/Q' jenkins_install.sh
cat <<here1 >> jenkins_install.sh
cat <<here >> /var/lib/jenkins/.aws/config
[default]
region=$Region
output=$Output
here
here1

#!/bin/bash

echo -ne "Enter the Project name: "
read PROJECT
BUCKET="LoadTesting"_$PROJECT
echo -ne "Enter the name of the jmx file: "
read jmxFile
echo -ne "Enter the number of users for the load test: "
read users
echo -ne "Enter the comma-separated values for loop count for the load test: "
read loops
echo -ne "Enter the success threshold for the load test: "
read Threshold
echo -ne "Enter the name of the output file: "
read OutputFile

> properties.sh

cat <<here >> properties.sh
export PROJECT=$PROJECT
export BUCKET=LoadTesting_$PROJECT
export jmxFile=$jmxFile
export OutputFile=$OutputFile
export users=$users
export loops=$loops
export Threshold=$Threshold
here

#create log file
touch ./$PROJECT.log
> ./$PROJECT.log

echo "About to configure aws cli!"
sleep 5

bash awscliconfig.sh | tee $PROJECT.log
sed -i '/PROJECT=/d' user_data_file.sh
sed -i '/PROJECT=/d' jmeter_master.sh
sed -i "/#!\/bin\/bash/a PROJECT=$PROJECT;BUCKET=$BUCKET" user_data_file.sh
sed -i "/#!\/bin\/bash/a PROJECT=$PROJECT;BUCKET=$BUCKET" jmeter_master.sh 

aws s3api create-bucket --bucket $BUCKET
aws s3 cp ./jenkins_install.sh s3://$BUCKET/jenkins_install.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./jmeter_master.sh s3://$BUCKET/jmeter_master.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
#aws s3 cp ./properties.sh s3://$BUCKET/properties.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
#aws s3 cp ./conversion.xml s3://$BUCKET/conversion.xml --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
#aws s3 cp ./jmeter-results-detail-report_21.xsl s3://$BUCKET/jmeter-results-detail-report_21.xsl --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers





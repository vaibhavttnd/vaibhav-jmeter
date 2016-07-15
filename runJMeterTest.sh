#!/bin/bash

#########EXECUTED THROUGH THE JENKINS JOB

source EC2instanceproperties.sh
source JMetertestproperties.sh

#create 2 S3 buckets
aws s3api create-bucket --bucket $BUCKET_RESULT
aws s3api create-bucket --bucket $BUCKET_INSTALL

#copy all necessary files so that jmeter master server can access them
aws s3 cp ./conversion.xml  s3://$BUCKET_INSTALL/conversion.xml  --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./jmeter-results-detail-report_21.xsl s3://$BUCKET_INSTALL/jmeter-results-detail-report_21.xsl --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./$jmxFile.jmx s3://$BUCKET_INSTALL/File.jmx --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./configJMeterSlave.sh s3://$BUCKET_INSTALL/configJMeterSlave.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./createSlave.sh s3://$BUCKET_INSTALL/createSlave.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./EC2instanceproperties.sh s3://$BUCKET_INSTALL/EC2instanceproperties.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./JMetertestproperties.sh s3://$BUCKET_INSTALL/JMetertestproperties.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./JMeterMasterRunTest.sh s3://$BUCKET_INSTALL/JMeterMasterRunTest.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

>jenkins.log

#call script to launch master-slave setup and run jmeter tests
bash -x launchJMeter.sh | tee jenkins.log

#copy logs to S3
aws s3 cp jenkins.log s3://$BUCKET_RESULT/Logs/jenkins.log --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers





#!/bin/bash

source EC2instanceproperties.sh
source JMetertestproperties.sh

aws s3api create-bucket --bucket $BUCKET_RESULT
aws s3api create-bucket --bucket $BUCKET_INSTALL

aws s3 cp ./conversion.xml  s3://$BUCKET_INSTALL/conversion.xml  --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./jmeter-results-detail-report_21.xsl s3://$BUCKET_INSTALL/jmeter-results-detail-report_21.xsl --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./$jmxFile.jmx s3://$BUCKET_INSTALL/File.jmx --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./configScriptSlave.sh s3://$BUCKET_INSTALL/configScriptSlave.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./createSlave.sh s3://$BUCKET_INSTALL/createSlave.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./EC2instanceproperties.sh s3://$BUCKET_INSTALL/EC2instanceproperties.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./JMetertestproperties.sh s3://$BUCKET_INSTALL/JMetertestproperties.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./jmeter_master.sh s3://$BUCKET_INSTALL/jmeter_master.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

>jenkins.log
bash -x launchJMeter.sh | tee jenkins.log

aws s3 cp jenkins.log s3://$BUCKET_RESULT/Logs/jenkins.log --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers





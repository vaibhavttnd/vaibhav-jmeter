#!/bin/bash

source instanceproperties.sh
source testproperties.sh

aws s3api create-bucket --bucket $BUCKET_RESULT
aws s3api create-bucket --bucket $BUCKET_INSTALL

aws s3 cp ./conversion.xml  s3://$BUCKET_INSTALL/conversion.xml  --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./jmeter-results-detail-report_21.xsl s3://$BUCKET_INSTALL/jmeter-results-detail-report_21.xsl --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./$jmxFile.jmx s3://$BUCKET_INSTALL/File.jmx --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./configScriptSlave s3://$BUCKET_INSTALL/configScriptSlave --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./slave.sh s3://$BUCKET_INSTALL/slave.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./instanceproperties.sh s3://$BUCKET_INSTALL/instanceproperties.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./testproperties.sh s3://$BUCKET_INSTALL/testproperties.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./jmeter_master.sh s3://$BUCKET_INSTALL/jmeter_master.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

>jenkins.log
bash -x launchJMeter.sh | tee jenkins.log

aws s3 cp jenkins.log s3://$BUCKET_RESULT/Logs/jenkins.log --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers





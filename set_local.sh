#!/bin/bash
set -e

touch /tmp/LoadTesting.log
> /tmp/LoadTesting.log

echo "About to configure aws cli!"
sleep 5

bash awscliconfig.sh | tee /tmp/LoadTesting.log

while [ true ]
do
        echo -ne "Enter project name: "
        read PROJECT
        if [ `aws s3 ls | grep LoadTesting_$PROJECT` ]
        then
                echo "Bucket already exists"
        else
                break
        fi
done
BUCKET_INSTALL="LoadTesting"_$PROJECT
BUCKET_RESULT="LoadTestingResults"_$PROJECT

> instanceproperties.sh
cat <<here >> instanceproperties.sh
export PROJECT=$PROJECT
export BUCKET_INSTALL=LoadTesting_$PROJECT
export BUCKET_RESULT=LoadTestingResults_$PROJECT
here

#sed -i '/PROJECT=/d' jenkins_install.sh
sed -i '/PROJECT=/d' jmeter_master.sh
#sed -i "/#!\/bin\/bash/a PROJECT=$PROJECT;BUCKET_INSTALL=$BUCKET_INSTALL;BUCKET_RESULT=LoadTestingResults_$PROJECT" jenkins_install.sh
sed -i "/#!\/bin\/bash/a PROJECT=$PROJECT;BUCKET_INSTALL=$BUCKET_INSTALL;BUCKET_RESULT=LoadTestingResults_$PROJECT" jmeter_master.sh

#aws s3api create-bucket --bucket $BUCKET_INSTALL
#aws s3 cp ./conversion.xml  s3://$BUCKET_INSTALL/conversion.xml  --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
#aws s3 cp ./jmeter-results-detail-report_21.xsl s3://$BUCKET_INSTALL/jmeter-results-detail-report_21.xsl --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
#aws s3 cp ./File.jmx s3://$BUCKET_INSTALL/File.jmx --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
#aws s3 cp ./configScriptSlave s3://$BUCKET_INSTALL/configScriptSlave --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
#aws s3 cp ./slave.sh s3://$BUCKET_INSTALL/slave.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

echo "About to launch Jenkins Master Instance!"
sleep 5
bash creation.sh | tee /tmp/LoadTesting.log
bash launchJenkins.sh | tee /tmp/LoadTesting.log

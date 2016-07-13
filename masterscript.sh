#!/bin/bash
set -e

touch /tmp/LoadTesting.log
> /tmp/LoadTesting.log

echo "About to configure aws cli!"
sleep 5

> EC2instanceproperties.sh
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

cat <<here >> EC2instanceproperties.sh
export PROJECT=$PROJECT
export BUCKET_INSTALL=LoadTesting_$PROJECT
export BUCKET_RESULT=LoadTestingResults_$PROJECT
here

sed -i '/PROJECT=/d' configScriptMaster.sh
sed -i "/#!\/bin\/bash/a PROJECT=$PROJECT;BUCKET_INSTALL=$BUCKET_INSTALL;BUCKET_RESULT=LoadTestingResults_$PROJECT;" configScriptMaster.sh

echo "About to launch Jenkins Master Instance!"
sleep 5
bash creationAWSresource.sh | tee /tmp/LoadTesting.log
bash launchJenkins.sh | tee /tmp/LoadTesting.log

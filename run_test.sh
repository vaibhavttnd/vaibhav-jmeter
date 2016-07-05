#!/bin/bash

<<<<<<< HEAD
source instanceproperties.sh
source testproperties.sh

aws s3api create-bucket --bucket $BUCKET_RESULT
aws s3api create-bucket --bucket $BUCKET_INSTALL

aws s3 cp ./conversion.xml  s3://$BUCKET_INSTALL/conversion.xml  --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./jmeter-results-detail-report_21.xsl s3://$BUCKET_INSTALL/jmeter-results-detail-report_21.xsl --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./File.jmx s3://$BUCKET_INSTALL/File.jmx --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./configScriptSlave s3://$BUCKET_INSTALL/configScriptSlave --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./slave.sh s3://$BUCKET_INSTALL/slave.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./instanceproperties.sh s3://$BUCKET_INSTALL/instanceproperties.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
aws s3 cp ./testproperties.sh s3://$BUCKET_INSTALL/testproperties.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

>jenkins.log
bash launchJMeter.sh  >> jenkins.log 2>&1

aws s3 cp jenkins.log s3://$BUCKET_RESULT/Logs/jenkins.log --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers




=======
source properties.sh
touch /usr/share/jmeter/extras/slave.log
>/usr/share/jmeter/extras/slave.log

bash -x /usr/share/jmeter/extras/slave.sh >> /usr/share/jmeter/extras/slave.log 2>&1

IPList=$(cat ip.txt |awk 'FNR==1{print $0}')
echo "Wait while slaves are configured!"
sleep 300
IFS=','
array=( $loops )
for i in ${array[@]}
do

>/usr/share/jmeter/extras/outputFile_$i.xml
sed -i '/<xslt/d' /usr/share/jmeter/extras/conversion.xml
sed -i '/<project/a <xslt in="/usr/share/jmeter/extras/outputFile_'$i'.xml" out="/usr/share/jmeter/extras/outputFile_'$i'.html"' /usr/share/jmeter/extras/conversion.xml

jmeter -n -t /usr/share/jmeter/extras/$jmxFile.jmx -l /usr/share/jmeter/extras/outputFile_"$i".xml -R $IPList -Gusers=$users -Gloops=$i;
ant -f /usr/share/jmeter/extras/conversion.xml
aws s3 cp /usr/share/jmeter/extras/outputFile_"$i".html s3://$BUCKET/$OutputFile"_"$i".html" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
Success=$(grep -o -m 1 '[0-9][0-9]*.[0-9][0-9]%' outputFile_$i.html | cut -d. -f1)
echo "No. of loops: "$i
echo "Success Rate: "$Success
echo https://s3.amazonaws.com/$BUCKET/$OutputFile"_"$i".html"

if [ $Success -ge $Threshold ]
then echo "Executing next test"
else
echo "Aborting!"
exit
fi

done
>>>>>>> 4a989098bd3f26709e2a6ee8e1f880ed6467e329

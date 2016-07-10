#!/bin/bash
source /usr/share/jmeter/extras/instanceproperties.sh
source /usr/share/jmeter/extras/testproperties.sh

>slave.log
IFS=','
array=( $users )

########################## for each iteration
for i in ${array[@]}
do
>/usr/share/jmeter/extras/outputFile_$i.xml
sed -i '/<xslt/d' /usr/share/jmeter/extras/conversion.xml
sed -i '/<project/a <xslt in="/usr/share/jmeter/extras/outputFile_'$i'.xml" out="/usr/share/jmeter/extras/outputFile_'$i'.html"' /usr/share/jmeter/extras/conversion.xml

#create slaves
bash -x /usr/share/jmeter/extras/slave.sh $i
echo "-----------------Please wait while Slaves are configured!--------------------"
sleep 300
source /usr/share/jmeter/extras/testproperties.sh

#read IP of all slaves
IPList=$(cat /usr/share/jmeter/extras/ip.txt |awk 'FNR==1{print $0}')

##############calculate no of users per slave
UsersPerSlave=$(expr $i / $SlavesNeeded)
R=$(expr $i % $SlavesNeeded)
if [ $R -ne 0 ]
then
	UsersPerSlave=$(expr $UsersPerSlave + 1)
fi

#run test
jmeter -n -t /usr/share/jmeter/extras/File.jmx -l /usr/share/jmeter/extras/outputFile_"$i".xml -R $IPList -Gusers=$UsersPerSlave;
ant -f /usr/share/jmeter/extras/conversion.xml

#copy result file to S3
aws s3 cp "/usr/share/jmeter/extras/outputFile_$i.html" s3://$BUCKET_RESULT/Result/$OutputFile"_"$i".html" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

#check for success threshold
Success=$(grep -o -m 1 '[0-9][0-9]*.[0-9][0-9]%' /usr/share/jmeter/extras/outputFile_$i.html | cut -d. -f1)
echo "No. of users: "$i
echo "Success Rate: "$Success
echo https://s3.amazonaws.com/$BUCKET_RESULT/$OutputFile"_"$i".html"

if [ $Success -ge $Threshold ]
then
	echo "Executing next test"
else
	echo "Aborting!"
	break
fi
done
echo "-----------------------------------------FINISHED--------------------------------------------------------------"
aws s3 cp "/var/log/cloud-init-output.log" s3://$BUCKET_RESULT/Logs/jmeter_logs.log --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

#####terminating all slave instances
cat /usr/share/jmeter/extras/RunningInstances.txt | while read LINE
do
        ID=$(aws ec2 describe-instances --filters "Name=ip-address,Values=$LINE" --query "Reservations[*].Instances.InstanceId" --output text)
        aws ec2 terminate-instances --instance-ids $ID
done

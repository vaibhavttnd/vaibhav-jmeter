#!/bin/bash

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
aws s3 cp /usr/share/jmeter/extras/outputFile.html s3://$BUCKET/$OutputFile_$i.html --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
Success=$(grep -o -m 1 '[0-9][0-9]*.[0-9][0-9]%' outputFile.html | cut -d. -f1)
echo "No. of loops: "$i
echo "Success Rate: "$Success
echo "https://s3.amazonaws.com/$BUCKET/$OutputFile_$i.html"

if [ $Success -ge $Threshold ]
then echo "Executing next test"
else
echo "Aborting!"
exit
fi

done

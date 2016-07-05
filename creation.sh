#!/bin/bash
source instanceproperties.sh
#aws s3api create-bucket --bucket $BUCKET_INSTALL
#aws s3 cp ./jmeter_master.sh s3://$BUCKET_INSTALL/jmeter_master.sh --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

echo -ne "Create VPC (y/n)? "
read create_VPC
if [ $create_VPC == 'y' ]
then
        echo -ne "Enter CIDR Block: "
        read cidr
        VPC=$(aws ec2 create-vpc --cidr-block $cidr | grep -o "vpc-[0-9,a-z,A-Z]*")
        aws ec2 create-tags --resources $VPC --tags Key=Name,Value=VPC_$PROJECT
        echo "VPC created, VpcId= "$VPC
	echo "Creating Internet Gateway!"
        IGW=`aws ec2 create-internet-gateway | grep -o "igw-[0-9,a-z,A-Z]*"`
        aws ec2 attach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC
        RTB=`aws ec2 create-route-table --vpc-id $VPC | grep -o "rtb-[0-9,a-z,A-Z]*"`
        echo "Done!"
else
	echo -ne "Enter VpcID: "
	read VPC
fi

echo -ne "Create Subnet (y/n)? "
read create_subnet
if [ $create_subnet == 'y' ]
then
	echo -ne "Enter CIDR Block: "
        read cidr
	Subnet=$(aws ec2 create-subnet --vpc-id $VPC --cidr-block $cidr | grep -o "subnet-[0-9,a-z,A-Z]*")
	aws ec2 create-tags --resources $Subnet --tags Key=Name,Value=Subnet_$PROJECT
        echo "Subnet created, Subnet Id= "$Subnet
	aws ec2 associate-route-table --route-table-id $RTB --subnet-id $Subnet
	aws ec2 create-route --route-table-id $RTB --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW
	
else
        echo -ne "Enter SubnetId: "
        read Subnet
fi

echo -ne "Create Security Group (y/n)? "
read create_sg
if [ $create_sg == 'y' ]
then
	echo -ne "Enter name of Security Group: "
	read SG
	SecurityGroup=$(aws ec2 create-security-group --group-name $SG --description "Load Testing Security Group" --vpc-id $VPC | grep -o "sg-[0-9,a-z,A-Z]*")
	aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 80 --cidr 0.0.0.0/0
	aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 22 --cidr 0.0.0.0/0
	aws ec2 authorize-security-group-ingress --group-id $SecurityGroup --protocol tcp --port 8080 --cidr 0.0.0.0/0
	echo "Security Group created, Security Group ID= "$SecurityGroup
else
	echo -ne "Enter Security Group Id: "
        read SecurityGroup
fi

echo -ne "Create Key Pair (y/n)? "
read create_key
echo "Enter name of Key pair: "
read KeyPairName
if [ $create_key == 'y' ]
then
	echo "Save the key in "$KeyPairName".pem"
	aws ec2 create-key-pair --key-name $KeyPairName
fi

cat <<here >> instanceproperties.sh
export VPC=$VPC
export Subnet=$Subnet
export SecurityGroup=$SecurityGroup
export KeyPairName=$KeyPairName
here









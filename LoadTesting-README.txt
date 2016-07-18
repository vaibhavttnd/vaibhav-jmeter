The following scripts are used to automate Load Testing using jmeter, ANT and Jenkins:
	awscliconfig.sh
	configJMeterMaster.sh
	configJMeterSlave.sh
	conversion.xml
	creationAWSresources.sh
	EC2instanceproperties.sh
	configJenkinsMaster.sh
	JMeterMasterRunTest.sh
	jmeter-results-detail-report_21.xsl
	launchJenkins.sh
	launchJMeter.sh
	LoadTesting-Permissions.json
	LoadTesting-README.txt
	LoadTesting-Trust.json
	masterscript.sh
	runJMeterTest.sh
	createSlave.sh
	JMetertestproperties.sh

Steps:

1. In your jmx file, under Thread Properties, set the value of 'Number of Threads (users)' as '${__P(users)}. Set 'Loop Count' as '1'.

2. Create a new Git repository and import code from https://github.com/gunjan-lal/loadtesting-demo.git to your own git repository.
Also, upload your .jmx file in your git repository.
Clone your git repository into your local system.
	git clone <URL>
The repository will be cloned into a new folder in your present working directory.

3. Change your directory into the one just created.

4. Create an empty Git repository: git init

5. Execute the masterscript.sh:
	sudo -i
	bash masterscript.sh
This script calls awscliconfig.sh which configures AWS CLI on your local system by taking your credentials as parameters. This takes a few minutes.
	#Enter Access Key
	#Enter Secret Access Key
	#Enter region
	#Enter output format
It also takes the Project Name as a parameter. The project name will not be accepted if a bucket of the name already exists.
	#Enter the name of the Project

Then, creationAWSresources.sh is executed, which creates a new VPC, Internet Gateway, Route Table, Subnet, Security Group and a key pair. IDs of existing resources can also be provided.
	#Create VPC (y/n)?
		if yes, #Enter CIDR Block
		if no, #Enter VPC ID
	#Create Subnet (y/n)?
		if yes, #Enter CIDR Block
		if no, #Enter Subnet ID
	#Create Security Group (y/n)?
		#Enter name of Security Group
	#Create Key Pair (y/n)?
		#Enter name of Key pair

Next, launchJenkins.sh is called which takes the AMI ID and the Instance type as parameters and creates a new IAM Role, Instance Profile and a Jenkins server.
	#Enter AMI ID
	#Enter Instance Type
	#Enter URL of the Git Repository
	#Enter your GitHub credentials
The Public IP of the server is displayed on the screen.
Wait while Jenkins Master Instance is configured. This may take a few minutes.
When the server is configured, the Jenkins administrator password will be displayed. Access the Public IP through your browser and enter the password.

5. Edit the JMetertestproperties.sh present in the same directory according to your test parameters.
	jmxFile: (name of the jmx file, without .jmx)
	OutputFile: (name of the output file, without .html)
	users: (comma separated list of virtual users for the Load Test)
	Load: (Maximum load, i.e., maximum number of users for one slave)
	Threshold: (Success threshold for the Load Test)
	JMeterKey: (Name of the Key Pair to be used for the JMeter master and slaves, this key will be created)

Push this file into your git repository.
	git add JMetertestproperties.sh
	git commit -m "JMetertestproperties"
	git push
	#Enter your GitHub credentials

6. Click on 'Install Suggested Plugins'. After the plugins are installed, create an administrator user. This user can be used to login to Jenkins anytime.

7. On the Jenkins Dashboard, go to Manage Jenkins->Configure System. Set '# of executors' to 1. Click Save.

8. Create a new job on the Jenkins Dashboard by following these steps:
	a) Click on 'New Item' on the Jenkins Dashboard. Create a Freestyle Project and enter a name. Click OK.
	b) Check GitHub Project and enter the URL of git repository.
	c) Under Source Code Management, check Git and enter the repository URL. Add your GitHub credentials (ID and Description are optional).
	d) Select 'Poll SCM' under 'Build Triggers' and enter 'H/5 * * * *' as the Schedule. This sets up the poll to occur every 5 minutes.
	In case there is a new commit, Build is triggered.
	e) Add a new Build step as 'Execute Shell' and enter the following commands:
		#!/bin/bash
		bash runJMeterTest.sh
	This will execute the script 'runJMetertest.sh' which creates JMeter master and slave servers to run the test.
	In the end, it uploads the HTML report to the S3 bucket.
	f) Save and Build the job
After the job is completed, go to the console output of the Build.

9. This job follows these steps:
	a) Creates two S3 Buckets, one for installation files and the other for Test reports and logs.
	b) Creates the JMeter master server and prints its Public IP.
	c) Calculates the number of slaves to be created according to the number of slaves already running.
	d) Calculates the number of users for each slave.
	e) Executes each test according to the parameters specified in JMetertestproperties.sh
	f) Each test is checked for its Success Rate. The job is aborted if any test fails to pass the Threshold.
	
10. The URL of the HTML report and the Success Rate of the test is displayed.

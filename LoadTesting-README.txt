The following scripts are used to automate Load Testing using jmeter, ANT and Jenkins:
	awscliconfig.sh
	configScriptSlave
	conversion.xml
	jenkins_install.sh
	jmeter_master.sh
	jmeter-results-detail-report_21.xsl
	launch_instance.sh
	LoadTesting-Permissions.json
	LoadTesting-Trust.json
	masterscript.sh
	properties.sh
	run_test.sh
	slave.sh
	user_data_file.sh
	LoadTesting-README.txt

Steps:

1. Copy all the files from https://github.com/gunjan-lal/jenkins_masterslave.git/ to your own git repository.  
Clone your git repository into your local system.
git clone <URL>
The repository will be cloned into a folder 'jenkins_masterslave' in your present working directory.
The .jmx file should also be present in this git repository. 

2. cd jenkins_masterslave

3. Create an empty Git repository: git init

4. Execute the masterscript.sh: bash masterscript.sh
This script creates a new S3 bucket and takes as input the names of Project, the .jmx file and the html reports which will be saved into the S3 bucket.
        #Enter the name of the Project
        #Enter the name of the jmx file (without .jmx)
        #Enter the name of the output HTML file (without .html)	
It also installs awscli on your system and configures aws by taking your credentials as parameters. This may take a few minutes.
	#Enter Access Key
	#Enter Secret Access Key
	#Enter region
	#Enter output format

5. Execute launch_instance.sh: bash launch_instance.sh
	#Enter AMI ID
	#Enter Instance Type
	#Enter Subnet ID
	#Enter Security Group ID
	#Enter Key Pair Name
	#Enter Number of slave instances to be created
	#Enter the URL of your Git Repository
This scripts takes the Master Instance configuration and the number of slaves as input and creates a configured master instance.
It also prints the IP of the created instance.
This may take a few minutes.
The Security Group should have the ports 22,80 and 8080 open.

6. As soon as the Master Instance is created, access the 8080 port of the Master Instance through your browser. This should display the Jenkins Dashboard running on the Master.

7. Go to Manage Jenkins->Manage Plugins and download the following plugins:
	GitHub Authentication Plugin
	GitHub Plugin
Click on 'Install without restart'.

8. Go to Manage Jenkins->Configure System. Set '# of executors' to 1. Click Save.

8. Create a new job on the Jenkins Dashboard by following these steps:
	a) Click on 'New Item' on the Jenkins Dashboard. Create a Freestyle Project and enter a name. Click OK.
	b) Check GitHub Project and enter the URL of git repository.
	c) Under Advanced Project Options, enter custom workspace as '/usr/share/jmeter/extras/'.
	d) Under Source Code Management, check Git and enter the repository URL and your credentials.
	e) Select 'Poll SCM' under 'Build Triggers' and enter 'H/5 * * * *' as the Schedule. This sets up the poll to occur every 5 minutes.
	In case there is a new commit, Build is triggered.
	f) Add a new Build step as 'Execute Shell' and enter the following commands:
		#!/bin/bash
		bash run_test.sh
	This will execute the script 'run_test.sh' which creates slave servers and runs the test.
	In the end, it uploads the HTML report to the S3 bucket.
	g) Build the job

9. This job creates slave instances and runs Load Test on the master slave setup. The configuration of slaves takes a few minutes.
After the job is completed, the URL of the HTML report is displayed and the report can be found in the S3 bucket.

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

1. Clone the git repository into your local system.
git clone <URL>
The repository will be cloned into a folder 'jenkins_masterslave' in your present working directory. The .jmx file should also be present in this git repository. 

2. cd jenkins_masterslave

3. Create an empty Git repository: git init

4. Execute the masterscript.sh: bash masterscript.sh
This scripts creates a new S3 bucket and takes as input the names of Project, the .jmx file and the html reports which will be saved into the S3 bucket. It also installs awscli on your system and configures aws by taking your credentials as parameters.

5. Execute launch_instance.sh: bash launch_instance.sh
This scripts takes the Master Instance configuration and the number of slaves as input and creates a configured master instance.
It also prints the IP of the created instance.

6. As soon as the Master Instance is created, access the 8080 port of the Master Instance through your browser. This should display the Jenkins Dashboard running on the Master.

7. Go to Manage Jenkins->Manage Plugins and download the following plugins:
	GitHub Authentication Plugin
	GitHub Plugin
8. Create a new job on the Jenkins Dashboard by following these steps:
	a) Create a Freestyle Project and enter a name. Click OK.
	b) Check GitHub Project and enter the URL of git repository.
	c) Under Advanced Project Options, enter custom workspace as '/usr/share/jmeter/extras/'.
	d) Under Source Code Management, check Git and enter the repository URL and your credentials.
	e) Select 'Poll SCM' under 'Build Triggers' and enter 'H/5 * * * *' as the Schedule. This sets up the poll to occur every 5 minutes. 		In case there is a new commit, Build is triggered.
	f) Add a new Build step as 'Execute Shell' and enter the following commands:
		#!/bin/bash
		bash run_test.sh
	This will execute the script 'run_test.sh' which creates slave servers and runs the test. In the end, it uploads the HTML report to 		the S3 bucket.
	g) Build the job
9. After the job is completed, the HTML report can be found in the S3 bucket.

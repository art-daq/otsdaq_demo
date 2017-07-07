#!/bin/bash

if ! [ -e setup_ots.sh ]; then
  kdialog --sorry "You must run this script from an OTSDAQ installation directory!"
  exit 1
fi

Base=$PWD
alloutput_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4".script"}' )
stderr_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4"_stderr.script"}' )
exec  > >(tee "$Base/log/$alloutput_file")
exec 2> >(tee "$Base/log/$stderr_file")

source setup_ots.sh

#Steps:
#	ask if user is sure they want to proceed to stop existing tutorial processes
#		if no, do nothing, done
#		if yes, stop processes and proceed
#
#	ask if user wants to reset tutorial data
#		if yes, replace user data and database with tutorial data
#		if no, do nothing and proceed
#
#	ask if user wants to startup tutorial processes
#		if no, do nothing, done
#		if yes, start emulator and normal mode



kdialog --yesno "Before (re)starting the tutorial, this script will stop existing tutorial process. Are you sure you want to proceed?"
if [[ $? -eq 1 ]];then #no
	echo "User decided to not continue with tutorial reset. Exiting script."
	kdialog --msgbox "User decided to not continue with tutorial reset. Exiting script."
	exit
fi


kdialog --yesno "Reset user data for 'First Demo' tutorial (setup data for the beginning of the tutorial)?"
if [[ $? -eq 0 ]];then #yes
	echo "User decided to reset to 'First Demo' tutorial data."
	
	########################################
	########################################
	## Setup USER_DATA and databases
	########################################
	########################################
	
	#Take from tutorial data 
	export USER_DATA="$MRB_SOURCE/otsdaq_demo/NoGitData"
		
	#... you must already have ots setup (i.e. $USER_DATA must point to the right place).. if you are using the virtual machine, this happens automatically when you start up the VM.
	
	#download get_tutorial_data script
	wget https://cdcvs.fnal.gov/redmine/projects/otsdaq/repository/demo/revisions/develop/raw/tools/get_tutorial_data.sh -O get_tutorial_data.sh
	
	#change permissions so the script is executable
	chmod 755 get_tutorial_data.sh
	
	#execute script
	./get_tutorial_data.sh
	
	
	export ARTDAQ_DATABASE_URI="filesystemdb://$MRB_SOURCE/otsdaq_demo/NoGitDatabases/filesystemdb/test_db"
	#... you must already have ots setup (i.e. $ARTDAQ_DATABASE_URI must point to the right place).. if you are using the virtual machine, this happens automatically when you start up the VM.
	
	#download get_tutorial_data script
	wget https://cdcvs.fnal.gov/redmine/projects/otsdaq/repository/demo/revisions/develop/raw/tools/get_tutorial_database.sh -O get_tutorial_database.sh
	
	#change permissions so the script is executable
	chmod 755 get_tutorial_database.sh
	
	#execute script
	./get_tutorial_database.sh
	
	########################################
	########################################
	## END Setup USER_DATA and databases
	########################################
	########################################
	

    echo "Now your user data path is USER_DATA = ${USER_DATA}"
    echo "Now your database path is ARTDAQ_DATABASE_URI = ${ARTDAQ_DATABASE_URI}"
fi



kdialog --yesno "Do you want to start the tutorial processes (i.e. the emulator and OTS in normal mode)?"
if [[ $? -eq 1 ]];then #no
	echo "User decided to not start the tutorial. Exiting script."
	kdialog --msgbox "User decided to not start the tutorial. Exiting script."
	exit
fi


echo "User decided to start up the tutorial."

StartOTS.sh --wiz #just to test activate the saved groups  
StartOTS.sh --chrome #launch normal mode and open chrome
#google-chrome http://otsdaq:2015/urn:xdaq-application:lid=200#1

#start hardware emulator on port 4000
ots_udp_hw_emulator 4000 &

echo
echo
echo "Tutorial reset script complete."
kdialog --msgbox "Tutorial reset script complete."

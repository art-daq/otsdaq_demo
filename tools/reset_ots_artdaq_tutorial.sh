#!/bin/bash

if ! [ -e setup_ots.sh ]; then
  kdialog --sorry "You must run this script from an OTSDAQ installation directory!"
  exit 1
fi

Base=$PWD
#commenting out unique filename generation
# no need to keep more than one past log for standard users 
#alloutput_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4".script"}' )
#stderr_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4"_stderr.script"}' )
#exec  > >(tee "$Base/log/$alloutput_file")
mkdir "$Base/script_log"  &>/dev/null #hide output
rm "$Base/script_log/$(basename $0).script" >/dev/null 2>&1
rm "$Base/script_log/$(basename $0)_stderr.script" >/dev/null 2>&1
exec  > >(tee "$Base/script_log/$(basename $0).script")
exec 2> >(tee "$Base/script_log/$(basename $0)_stderr.script")

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



kdialog --yesno "This script will start the artdaq tutorial.\n\nBefore (re)starting the tutorial, this script will stop any existing tutorial process.\n\nDo you want to proceed?\n"
if [[ $? -eq 1 ]];then #no
	echo "User decided to not continue with starting the tutorial. Exiting script."
	kdialog --msgbox "You decided to not continue with starting the tutorial. Exiting script."
	exit
fi

StartOTS.sh --killall
killall -9 ots_udp_hw_emulator

kdialog --yesno "Do you want to reset user data for the 'artdaq Demo' tutorial (i.e. setup data for the beginning of the tutorial)?"
if [[ $? -eq 0 ]];then #yes


	dbusRef=`kdialog --progressbar "Installing 'artdaq Demo' tutorial user data and database..." 5`
	qdbus $dbusRef Set "" value 1
	
	echo "User decided to reset to 'artdaq Demo' tutorial data."
	
	########################################
	########################################
	## Setup USER_DATA and databases
	########################################
	########################################
	
	#Take from tutorial data 

	if [ "x$USER_DATA" == "x" ]; then
		#export USER_DATA="$MRB_SOURCE/otsdaq_demo/NoGitData"
		echo "Error! You must already have ots setup (i.e. $USER_DATA must point to the right place)... For example, export USER_DATA=$MRB_SOURCE/otsdaq_demo/NoGitData. Exiting script."
		kdialog --msgbox "Error! You must already have ots setup (i.e. $USER_DATA must point to the right place)... For example, export USER_DATA=$MRB_SOURCE/otsdaq_demo/NoGitData. Exiting script."
		exit
	fi
		
	#... you must already have ots setup (i.e. $USER_DATA must point to the right place).. if you are using the virtual machine, this happens automatically when you start up the VM.
	
	#download get_tutorial_artdaq_data script
	wget https://cdcvs.fnal.gov/redmine/projects/otsdaq/repository/demo/revisions/develop/raw/tools/get_tutorial_artdaq_data.sh -O get_tutorial_artdaq_data.sh
	qdbus $dbusRef Set "" value 2
	
	#change permissions so the script is executable
	chmod 755 get_tutorial_artdaq_data.sh
	
	#execute script
	./get_tutorial_artdaq_data.sh
	qdbus $dbusRef Set "" value 3
	

	if [ "x$ARTDAQ_DATABASE_URI" == "x" ]; then
		#export ARTDAQ_DATABASE_URI="filesystemdb://$MRB_SOURCE/otsdaq_demo/NoGitDatabases/filesystemdb/test_db"
		echo "Error! You must already have ots setup (i.e. $ARTDAQ_DATABASE_URI must point to the right place)... For example, export USER_DATA=filesystemdb://$MRB_SOURCE/otsdaq_demo/NoGitDatabases/filesystemdb/test_db. Exiting script."
		kdialog --msgbox "Error! You must already have ots setup (i.e. $ARTDAQ_DATABASE_URI must point to the right place)... For example, export USER_DATA=$MRB_SOURCE/otsdaq_demo/NoGitData. Exiting script."
		exit
	fi
	
	#... you must already have ots setup (i.e. $ARTDAQ_DATABASE_URI must point to the right place).. if you are using the virtual machine, this happens automatically when you start up the VM.
	
	#download get_tutorial_artdaq_data script
	wget https://cdcvs.fnal.gov/redmine/projects/otsdaq/repository/demo/revisions/develop/raw/tools/get_tutorial_artdaq_database.sh -O get_tutorial_artdaq_database.sh
	qdbus $dbusRef Set "" value 4
	
	#change permissions so the script is executable
	chmod 755 get_tutorial_artdaq_database.sh
	
	#execute script
	./get_tutorial_artdaq_database.sh
	qdbus $dbusRef Set "" value 5
	
	########################################
	########################################
	## END Setup USER_DATA and databases
	########################################
	########################################
	
	qdbus $dbusRef close
	
    echo "Now your user data path is USER_DATA = ${USER_DATA}"
    echo "Now your database path is ARTDAQ_DATABASE_URI = ${ARTDAQ_DATABASE_URI}"
	

	#clean up
	rm get_tutorial_artdaq_database.sh
	rm get_tutorial_artdaq_data.sh
fi



kdialog --yesno "Do you want to start the tutorial processes (i.e. the emulator and OTS in normal mode)?"
if [[ $? -eq 1 ]];then #no
	echo "User decided to not start the tutorial. Exiting script."
	kdialog --msgbox "You decided to not start the tutorial. Exiting script."
	exit
fi


echo "User decided to start up the tutorial."

dbusRef=`kdialog --progressbar "Starting tutorial and launching OTS..." 4`
qdbus $dbusRef Set "" value 1

StartOTS.sh --wiz #just to test activate the saved groups  
qdbus $dbusRef Set "" value 2

StartOTS.sh --chrome #launch normal mode and open chrome
qdbus $dbusRef Set "" value 3

#start hardware emulator on port 4000
ots_udp_hw_emulator 4000 &
qdbus $dbusRef Set "" value 4

echo
echo
echo "Tutorial reset script complete."

qdbus $dbusRef close

kdialog --msgbox "Tutorial reset script complete."
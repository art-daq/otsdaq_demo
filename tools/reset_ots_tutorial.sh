#!/bin/bash
# reset_ots_tutorial.sh
#	Launches the specified otsdaq tutorial (and version). If no tutorial name is specified
#	it will default to first_demo.
#
# usage: --tutorial <tutorial name> --version <version string>
#
#   tutorial 
#		e.g. ${TUTORIAL} or artdaq
#   version 
#		usually looks like v2_2 to represent v2.2 release, for example 
#		(underscores might more universal for web downloads than periods)
#
#  example run:
#	./reset_ots_tutorial.sh --tutorial first_demo --version v2_2
#

#setup default parameters
TUTORIAL='first_demo'
VERSION='v2_2'

echo
echo "  |"
echo "  |"
echo "  |"
echo " _|_"
echo " \ /"
echo "  - "
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t ========================================================"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Please source this script, run it as source reset_ots_tutorial.sh"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t usage: --tutorial <tutorial name> --version <version string>"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t note: tutorial will default to '${TUTORIAL} ${VERSION}'"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t for example..."
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t\t source reset_ots_tutorial.sh --tutorial first_demo --version v2_2"


SOURCEDCHECK=$(basename $0&>/dev/null 2>&1 && echo "hi") #use to check if script was sourced or ./ ran (and avoid printint anything out)

if [ "x$SOURCEDCHECK" != "x" ]; then
	#detects if not sourced! Require source so that non-kdialog route works
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Not sourced. Exiting."	
	exit
fi	

#return  >/dev/null 2>&1 #return is used if script is sourced


echo
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Extracting parameters..."
echo


if [[ "$1"  == "--tutorial" && "x$2" != "x" ]]; then
	TUTORIAL="$2"
fi

if [[ "$3"  == "--version" && "x$4" != "x" ]]; then
	VERSION="$4"
fi

echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t TUTORIAL \t= $TUTORIAL"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t VERSION  \t= $VERSION"
echo		

#determine if kdialog is functional 
# if not alias to echo
KDIALOG_ALWAYS_YES=0
kdialog --print-winid &>/dev/null #hide output
if [[ $? -eq 1 ]];then #no
	#instead of e.g. /usr/bin/kdialog
	# only works if the script was sourced!
	alias kdialog="echo"
	which kdialog
	KDIALOG_ALWAYS_YES=1
	#echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t kdialog is not functional, attempt to bypass with alias echo and KDIALOG_ALWAYS_YES"
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t kdialog is not functional, bypassing user prompts"	
	echo

	source setup_ots.sh

	StartOTS.sh --killall
	killall -9 ots_udp_hw_emulator
	
	#download and run get_tutorial_data script
	wget https://cdcvs.fnal.gov/redmine/projects/otsdaq/repository/demo/revisions/develop/raw/tools/get_tutorial_data.sh -O get_tutorial_data.sh
	chmod 755 get_tutorial_data.sh
	./get_tutorial_data.sh --tutorial ${TUTORIAL} --version ${VERSION}
		
	#download and run get_tutorial_database script
	wget https://cdcvs.fnal.gov/redmine/projects/otsdaq/repository/demo/revisions/develop/raw/tools/get_tutorial_database.sh -O get_tutorial_database.sh	
	chmod 755 get_tutorial_database.sh
	./get_tutorial_database.sh --tutorial ${TUTORIAL} --version ${VERSION}
	
	#clean up
	rm get_tutorial_database.sh
	rm get_tutorial_data.sh

	StartOTS.sh --wiz #just to test activate the saved groups  
	StartOTS.sh  #launch normal mode and open chrome
	
	#start hardware emulator on port 4000
	ots_udp_hw_emulator 4000 &

	echo
	echo
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Tutorial reset script complete."
	
	return  >/dev/null 2>&1 #return is used if script is sourced
	exit  #exit is used if script is run ./reset...
fi


if ! [ -e setup_ots.sh ]; then
  kdialog --sorry "You must run this script from an OTSDAQ installation directory!"
  return  >/dev/null 2>&1 #return is used if script is sourced
  exit  #exit is used if script is run ./reset...
fi


Base=$PWD

#commenting out unique filename generation
# no need to keep more than one past log for standard users 
#alloutput_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4".script"}' )
#stderr_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4"_stderr.script"}' )


mkdir "$Base/script_log"  &>/dev/null #hide output
SCRIPTNAME='reset_ots_tutorial'

rm "$Base/script_log/${SCRIPTNAME}.script" >/dev/null 2>&1
rm "$Base/script_log/${SCRIPTNAME}_stderr.script" >/dev/null 2>&1
exec  > >(tee "$Base/script_log/${SCRIPTNAME}.script")
exec 2> >(tee "$Base/script_log/${SCRIPTNAME}_stderr.script")

echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Script log saved here $Base/script_log/${SCRIPTNAME}.script and $Base/script_log/${SCRIPTNAME}_stderr.script"

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



kdialog --yesno "This script starts otsdaq tutorials.\n\nBefore (re)starting the tutorial, this script will stop any existing tutorial process.\n\nDo you want to proceed?\n"
if [[ $KDIALOG_ALWAYS_YES == 0 && $? -eq 1 ]];then #no
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t User decided NOT to continue with starting the tutorial. Exiting script."
	kdialog --msgbox "You decided NOT to continue with starting the tutorial. Exiting script."
	return
	exit
fi

StartOTS.sh --killall
killall -9 ots_udp_hw_emulator

kdialog --yesno "Do you want to reset user data and database for the '${TUTORIAL} ${VERSION}' otsdaq tutorial (i.e. setup your ots installation for the beginning of the tutorial)?"
if [[ $KDIALOG_ALWAYS_YES == 1 || $? -eq 0 ]]; then #yes


	dbusRef=`kdialog --progressbar "Installing '${TUTORIAL} ${VERSION}' tutorial user data and database..." 5`
	qdbus $dbusRef Set "" value 1
	
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t User decided to reset to '${TUTORIAL} ${VERSION}' tutorial data."
	
	########################################
	########################################
	## Setup USER_DATA and databases
	########################################
	########################################
	
	#Take from tutorial data

	
	if [ "x$USER_DATA" == "x" ]; then		
		echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Error! You must already have ots setup (i.e. $USER_DATA must point to the right place)... For example, export USER_DATA=$MRB_SOURCE/otsdaq_demo/NoGitData. Exiting script."
		kdialog --msgbox "Error! You must already have ots setup (i.e. $USER_DATA must point to the right place)... For example, export USER_DATA=$MRB_SOURCE/otsdaq_demo/NoGitData. Exiting script."
		return
		exit
	fi
		
	#... you must already have ots setup (i.e. $USER_DATA must point to the right place).. if you are using the virtual machine, this happens automatically when you start up the VM.
	
	#download get_tutorial_data script
	wget https://cdcvs.fnal.gov/redmine/projects/otsdaq/repository/demo/revisions/develop/raw/tools/get_tutorial_data.sh -O get_tutorial_data.sh
	qdbus $dbusRef Set "" value 2
	
	#change permissions so the script is executable
	chmod 755 get_tutorial_data.sh
	
	#execute script
	./get_tutorial_data.sh --tutorial ${TUTORIAL} --version ${VERSION}
	qdbus $dbusRef Set "" value 3

	if [ "x$ARTDAQ_DATABASE_URI" == "x" ]; then
		#export ARTDAQ_DATABASE_URI="filesystemdb://$MRB_SOURCE/otsdaq_demo/NoGitDatabases/filesystemdb/test_db"
		echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Error! You must already have ots setup (i.e. $ARTDAQ_DATABASE_URI must point to the right place)... For example, export USER_DATA=filesystemdb://$MRB_SOURCE/otsdaq_demo/NoGitDatabases/filesystemdb/test_db. Exiting script."
		kdialog --msgbox "Error! You must already have ots setup (i.e. $ARTDAQ_DATABASE_URI must point to the right place)... For example, export USER_DATA=$MRB_SOURCE/otsdaq_demo/NoGitData. Exiting script."
		return
		exit
	fi
			
	#... you must already have ots setup (i.e. $ARTDAQ_DATABASE_URI must point to the right place).. if you are using the virtual machine, this happens automatically when you start up the VM.
	
	#download get_tutorial_data script
	wget https://cdcvs.fnal.gov/redmine/projects/otsdaq/repository/demo/revisions/develop/raw/tools/get_tutorial_database.sh -O get_tutorial_database.sh
	qdbus $dbusRef Set "" value 4
	
	#change permissions so the script is executable
	chmod 755 get_tutorial_database.sh
	
	#execute script
	./get_tutorial_database.sh --tutorial ${TUTORIAL} --version ${VERSION}
	qdbus $dbusRef Set "" value 5
	
	########################################
	########################################
	## END Setup USER_DATA and databases
	########################################
	########################################
	
	qdbus $dbusRef close
	
    echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Now your user data path is USER_DATA = ${USER_DATA}"
    echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Now your database path is ARTDAQ_DATABASE_URI = ${ARTDAQ_DATABASE_URI}"
	
	#clean up
	rm get_tutorial_database.sh
	rm get_tutorial_data.sh
fi



kdialog --yesno "Do you want to start the otsdaq tutorial processes (i.e. the emulator and ots in normal mode)?"
if [[ $KDIALOG_ALWAYS_YES == 1 || $? -eq 1 ]];then #no
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t User decided NOT to start the tutorial. Exiting script."
	kdialog --msgbox "You decided NOT to start the tutorial. Exiting script."
	return
	exit
fi


echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t User decided to start up the tutorial."

dbusRef=`kdialog --progressbar "Starting tutorial and launching ots..." 4`
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
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Tutorial reset script complete."

qdbus $dbusRef close

kdialog --msgbox "Tutorial reset script complete."

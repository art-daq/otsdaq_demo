#!/bin/bash
# reset_ots_tutorial.sh
#	Launches the specified otsdaq tutorial. If no tutorial name is specified
#	it will default to first_demo.
#
# usage: --tutorial <tutorial name>
#
#   tutorial 
#		e.g. ${TUTORIAL} or artdaq
#
#  example run:
#	./reset_ots_tutorial.sh --tutorial first_demo
#
#	NOTE: if kdialog is not installed this script must be sourced to bypass kdialog prompts
#		e.g. source reset_ots_tutorial.sh --tutorial first_demo
#
# export KDIALOG_ALWAYS_YES=1	 # to force yes answer and no kdialog popups

#setup default parameters
TUTORIAL='first_demo'

echo
echo "  |"
echo "  |"
echo "  |"
echo " _|_"
echo " \ /"
echo "  - "
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t ========================================================"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t usage: --tutorial <tutorial name>"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t note: tutorial will default to '${TUTORIAL}'"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t for example..."
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t\t ./reset_ots_tutorial.sh --tutorial first_demo"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t NOTE: This script uses kdialog for prompts. If kdialog is not installed this script must be sourced to bypass kdialog prompts"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t	e.g. source reset_ots_tutorial.sh --tutorial first_demo"


#return  >/dev/null 2>&1 #return is used if script is sourced


echo
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Extracting parameters..."
echo

TUTORIALS_STRING="first_demo artdaq nim_plus iterator mu2e_roc mu2e_dcs slow_controls"

if [[ "$1"  == "--tutorial" && "x$2" != "x" ]]; then
	TUTORIAL="$2"
elif [[ "$1"  == "--list" || "$1"  == "--help" ]]; then
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t --list found. Listing recommended parameter values..."
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t\t Tutorials = ${TUTORIALS_STRING}"
	exit
elif [[ "x$1" != "x" ]]; then

	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Illegal parameters.. See above for usage."
	return  >/dev/null 2>&1 #return is used if script is sourced
	exit  #exit is used if script is run ./reset...
fi



if ! [ -e setup_ots.sh ]; then
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t You must run this script from an OTSDAQ installation directory with a setup_ots.sh script!"
	return  >/dev/null 2>&1 #return is used if script is sourced
	exit  #exit is used if script is run ./reset...
fi
	
shopt -s expand_aliases #allows for aliases in non-interactive mode (which apparently is critical depending on the temperment of the terminal)
source setup_ots.sh


echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t TUTORIAL \t= $TUTORIAL"
echo		

#determine if kdialog is functional 
# if not alias to echo


unalias kdialog >/dev/null 2>&1 
KDIALOG_TEST="$(which kdialog 2>&1)"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t KDIALOG_TEST  \t= $KDIALOG_TEST"
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t KDIALOG_ALWAYS_YES  \t= $KDIALOG_ALWAYS_YES"		
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t DISPLAY  \t= $DISPLAY"		

if [[ $KDIALOG_ALWAYS_YES == 1 || "$KDIALOG_TEST" == *"no kdialog"* || "x$DISPLAY" == "x" ]]; then #no
	#instead of e.g. /usr/bin/kdialog
	# note: auto recognition only works if the script was sourced!

	alias kdialog="echo"
	which kdialog
	KDIALOG_ALWAYS_YES=1
	
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t kdialog is disabled, bypassing user prompts"	
	echo


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

	ots --killall
	killall -9 ots_udp_hw_emulator

	#download and run get_tutorial_data script
	rm -rf get_tutorial_data.sh >/dev/null 2>&1
	wget https://raw.githubusercontent.com/art-daq/otsdaq_demo/develop/tools/get_tutorial_data.sh \
		--no-check-certificate \
		-O get_tutorial_data.sh
	chmod 755 get_tutorial_data.sh
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Getting tutorial Data..."
	./get_tutorial_data.sh --tutorial ${TUTORIAL}
				
	#clean up
	rm get_tutorial_data.sh


	#usually skip tutorial launch is run during quick_ots_install.sh
	if [ $SKIP_TUTORIAL_LAUNCH == 1 ]; then
		echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Skipping tutorial launch flag is set..."

		#seems to help on clean install
		source setup_ots.sh  >/dev/null 2>&1
		UpdateOTS.sh --tables >/dev/null 2>&1
		mb
		ots --wiz #just to test activate the saved groups 
		ots -k 

		echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Tutorial reset script complete."
		unalias kdialog
		return  >/dev/null 2>&1 #return is used if script is sourced
		exit  #exit is used if script is run ./reset...
	fi

	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Launching tutorial..."

	ots --wiz #just to test activate the saved groups  
	ots  #launch normal mode (and open firefox)
	
	#start hardware emulator on port 4000
	ots_udp_hw_emulator 4000 &

	echo
	echo
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Tutorial reset script complete."

	unalias kdialog
	return  >/dev/null 2>&1 #return is used if script is sourced
	exit  #exit is used if script is run ./reset...
else
	KDIALOG_ALWAYS_YES=0
fi

#for testing KDIALOG ALWAYS
#echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t KDIALOG_ALWAYS_YES  \t= $KDIALOG_ALWAYS_YES"
#return  >/dev/null 2>&1 #return is used if script is sourced


if ! [ -e setup_ots.sh ]; then
  kdialog --sorry "You must run this script from an OTSDAQ installation directory!"
  return  >/dev/null 2>&1 #return is used if script is sourced
  exit  #exit is used if script is run ./reset...
fi

echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Using kdialog for tutorial reset."

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

	return  >/dev/null 2>&1 #return is used if script is sourced
	exit
fi

ots --killall
killall -9 ots_udp_hw_emulator

#if no parameters and kdialog is working, check which tutorial the user wants
if [[ $KDIALOG_ALWAYS_YES == 0 && "x$1" == "x" ]]; then
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t No user parameters found, so checking which tutorial to run."
	
	kdialog --yesno "Do you want to proceed with the default tutorial, '${TUTORIAL}?'\n\n(if not, you will be prompted for tutorial name)"
	if [[ $? -eq 1 ]]; then #no
	
		TUTORIAL=$(kdialog --combobox "Please select the desired tutorial name:" "first_demo" "nim_plus" "iterator" "artdaq" --default "first_demo")
		
	fi
	
fi

echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t TUTORIAL \t= $TUTORIAL"
echo		

kdialog --yesno "Do you want to reset user data and database for the '${TUTORIAL}' otsdaq tutorial (i.e. setup your ots installation for the beginning of the tutorial)?"
if [[ $KDIALOG_ALWAYS_YES == 1 || $? -eq 0 ]]; then #yes


	dbusRef=`kdialog --progressbar "Installing '${TUTORIAL}' tutorial user data and database..." 5`
	qdbus $dbusRef Set "" value 1
	
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t User decided to reset to '${TUTORIAL}' tutorial data."
	
	########################################
	########################################
	## Setup USER_DATA and databases
	########################################
	########################################
	
	#Take from tutorial data

	
	if [ "x$USER_DATA" == "x" ]; then		
		echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Error! You must already have ots setup (i.e. $USER_DATA must point to the right place)... For example, export USER_DATA=$MRB_SOURCE/otsdaq_demo/NoGitData. Exiting script."
		kdialog --msgbox "Error! You must already have ots setup (i.e. $USER_DATA must point to the right place)... For example, export USER_DATA=$MRB_SOURCE/otsdaq_demo/NoGitData. Exiting script."

		return  >/dev/null 2>&1 #return is used if script is sourced
		exit
	fi
		
	if [ "x$ARTDAQ_DATABASE_URI" == "x" ]; then
		#export ARTDAQ_DATABASE_URI="filesystemdb://$MRB_SOURCE/otsdaq_demo/NoGitDatabases/filesystemdb/test_db"
		echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Error! You must already have ots setup (i.e. $ARTDAQ_DATABASE_URI must point to the right place)... For example, export USER_DATA=filesystemdb://$MRB_SOURCE/otsdaq_demo/NoGitDatabases/filesystemdb/test_db. Exiting script."
		kdialog --msgbox "Error! You must already have ots setup (i.e. $ARTDAQ_DATABASE_URI must point to the right place)... For example, export USER_DATA=$MRB_SOURCE/otsdaq_demo/NoGitData. Exiting script."

		return  >/dev/null 2>&1 #return is used if script is sourced
		exit
	fi

	#download get_tutorial_data script
	rm -rf get_tutorial_data.sh >/dev/null 2>&1
	wget https://raw.githubusercontent.com/art-daq/otsdaq_demo/develop/tools/get_tutorial_data.sh \
		--no-check-certificate \
		-O get_tutorial_data.sh
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Getting tutorial Data..."
	qdbus $dbusRef Set "" value 2
	
	#change permissions so the script is executable
	chmod 755 get_tutorial_data.sh
	
	#execute script
	./get_tutorial_data.sh --tutorial ${TUTORIAL}
	qdbus $dbusRef Set "" value 3

	
	########################################
	########################################
	## END Setup USER_DATA and databases
	########################################
	########################################
	
	qdbus $dbusRef close
	
    echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Now your user data path is USER_DATA = ${USER_DATA}"
    echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Now your database path is ARTDAQ_DATABASE_URI = ${ARTDAQ_DATABASE_URI}"
	
	#clean up
	rm get_tutorial_data.sh
fi


########################################
########################################
## START extra steps for specific tutorials
########################################
########################################


if [[ "$TUTORIAL"  == "nim_plus" ]]; then

	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Starting the ${TUTORIAL} tutorial extra steps..."
	mv install_ots_repo.sh install_ots_repo.sh.bk >/dev/null 2>&1
	wget https://raw.githubusercontent.com/art-daq/otsdaq_prepmodernization/develop/tools/install_ots_repo.sh \
		--no-check-certificate \
		-O install_ots_repo.sh
	source install_ots_repo.sh #install prep modernization repo and table definitions
	rm -rf install_ots_repo.sh
	mv install_ots_repo.sh.bk install_ots_repo.sh  >/dev/null 2>&1
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Done with the ${TUTORIAL} tutorial extra steps."
	
else
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t No extra steps needed for the ${TUTORIAL} tutorial."
fi

########################################
########################################
## END extra steps for specific tutorials
########################################
########################################


kdialog --yesno "Do you want to start the otsdaq tutorial processes (i.e. the emulator and ots in normal mode)?"
if [[ $KDIALOG_ALWAYS_YES == 1 || $? -eq 1 ]];then #no
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t User decided NOT to start the tutorial. Exiting script."
	kdialog --msgbox "You decided NOT to start the tutorial. Exiting script."
	return  >/dev/null 2>&1 #return is used if script is sourced
	exit
fi

#if script is sourced, stop here before running executables
return  >/dev/null 2>&1 #return is used if script is sourced
		
		
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t User decided to start up the tutorial."

dbusRef=`kdialog --progressbar "Starting tutorial and launching ots..." 7`
qdbus $dbusRef Set "" value 1

ots --wiz #just to test activate the saved groups  
qdbus $dbusRef Set "" value 2

sleep 3 #give time to activate configuration
qdbus $dbusRef Set "" value 3
sleep 3 #give time to activate configuration
qdbus $dbusRef Set "" value 4
sleep 3 #give time to activate configuration
qdbus $dbusRef Set "" value 5

#start hardware emulator on port 4000
ots_udp_hw_emulator 4000 &
qdbus $dbusRef Set "" value 6

kdialog --yesno "Do you want this script to launch your web browser?"
if [[ $KDIALOG_ALWAYS_YES == 1 || $? -eq 1 ]];then #no
	echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t User decided NOT to launch web browser. Exiting script."
	ots
	qdbus $dbusRef Set "" value 7
	qdbus $dbusRef close
	kdialog --msgbox "You decided NOT to launch web browser. Tutorial reset script complete."
	return  >/dev/null 2>&1 #return is used if script is sourced
	exit
fi

ots --firefox #launch normal mode and open firefox
qdbus $dbusRef Set "" value 7

echo
echo
echo -e `date +"%h%y %T"` "reset_ots_tutorial.sh [${LINENO}]  \t Tutorial reset script complete."

rm -f /tmp/postdata$$ /tmp/at_p$$ $REDMINE_LOGIN_COOKIEF $REDMINE_LOGIN_LISTF*; unset SKIP_REDMINE_LOGIN

qdbus $dbusRef close

kdialog --msgbox "Tutorial reset script complete."

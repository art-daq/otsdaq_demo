#!/bin/bash

if ! [ -e setup_ots.sh ]; then
  kdialog --error "You must run this script from an OTSDAQ installation directory!"
  exit 1
fi

Base=$PWD
alloutput_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4".script"}' )
stderr_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4"_stderr.script"}' )
exec  > >(tee "$Base/log/$alloutput_file")
exec 2> >(tee "$Base/log/$stderr_file")

source setup_ots.sh


#ask if user is sure they want to reset ots
# if no, do nothing, done
# if yes, proceed

#ask if user wants to reset ots for the 'First Demo' tutorial
# if yes, replace user data and database with tutorial data
# else, ask if user want to resest ots to the default starting point
#	if yes, replace user data and database with otsdaq_demo repo data
#	else, do nothing, done

kdialog --yesno "Are you sure you want to reset OTS (and clear all user data)?"
if [[ $? -eq 1 ]];then #no
	echo "User decided to not continue with reset. Exiting reset script."
	exit
fi


kdialog --yesno "Reset user data for 'First Demo' tutorial?"
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
	

    echo "Now your user data path is USER_DATA = \${USER_DATA}"
    echo "Now your database path is ARTDAQ_DATABASE_URI = \${ARTDAQ_DATABASE_URI}"
	
	echo
	echo
	echo "reset script complete."
	exit
fi

kdialog --yesno "Reset user data to default data?"
if [[ $? -eq 1 ]];then #no
	echo "User decided to not reset user data. Exiting reset script."
	exit
fi


echo "User decided to reset to default data."

########################################
########################################
## Setup USER_DATA and databases defaults
########################################
########################################
cp -a $MRB_SOURCE/otsdaq_demo/NoGitData $MRB_SOURCE/otsdaq_demo/NoGitData.bak
cp -a $MRB_SOURCE/otsdaq_demo/Data $MRB_SOURCE/otsdaq_demo/NoGitData

cp -a $MRB_SOURCE/otsdaq_demo/NoGitDatabases $MRB_SOURCE/otsdaq_demo/NoGitDatabases.bak
cp -a $MRB_SOURCE/otsdaq_demo/databases $MRB_SOURCE/otsdaq_demo/NoGitDatabases

export USER_DATA="$MRB_SOURCE/otsdaq_demo/NoGitData"
export ARTDAQ_DATABASE_URI="filesystemdb://$MRB_SOURCE/otsdaq_demo/NoGitDatabases/filesystemdb/test_db"

echo "Now your user data path is USER_DATA = \${USER_DATA}"
echo "Now your database path is ARTDAQ_DATABASE_URI = \${ARTDAQ_DATABASE_URI}"

echo
echo
echo "reset script complete."

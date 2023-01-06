#!/bin/bash

# usage: --tutorial <tutorial name>
#
#   tutorial 
#		e.g. ${TUTORIAL} or artdaq
#
#  example run:
#	./get_tutorial_data.sh --tutorial first_demo
#

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
#exec 2> >(tee "$Base/script_log/$stderr_file")
exec 2> >(tee "$Base/script_log/$(basename $0)_stderr.script")


#setup default parameters
TUTORIAL='first_demo'

if [[ "$1"  == "--tutorial" && "x$2" != "x" ]]; then
	TUTORIAL="$2"
fi

echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t TUTORIAL \t= $TUTORIAL"
echo		

shopt -s expand_aliases #allows for aliases in non-interactive mode (which apparently is critical depending on the temperment of the terminal)
source setup_ots.sh

echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t ********************************************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t ************ Gettings otsdaq tutorial Data (user settings, etc.)... ************"
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t ********************************************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t "


if [ "x$USER_DATA" == "x" ]; then
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Error."
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Environment variable USER_DATA not setup!"
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t To setup, use 'export USER_DATA=<path to user data>'"
	echo 
	echo
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t (If you do not have a user data folder copy '<path to ots source>/otsdaq-demo/Data' as your starting point.)"
	echo
	exit    
fi

#Steps:
# download tutorial user data
# bkup current user data
# move download user data into position


#attempt to mkdir for full path so that it exists to move the user data to
# assuming mkdir is non-destructive
PATH_ARR=$(echo ${USER_DATA} | tr '/' "\n")
UD_PATH=""
for UD_EL in ${PATH_ARR[@]}
do
	#echo $UD_EL
	#echo $UD_PATH
	mkdir $UD_PATH &>/dev/null #hide output
	UD_PATH="$UD_PATH/$UD_EL"
done

if [ "x$ARTDAQ_DATABASE_URI" == "x" ]; then
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Error."
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Environment variable ARTDAQ_DATABASE_URI not setup!"
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t To setup, use 'export ARTDAQ_DATABASE_URI=filesystemdb://<path to database>'" 
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t            e.g. filesystemdb:///home/rrivera/databases/filesystemdb/test_db"
	echo 
	echo 
	echo
	exit    
fi

#Steps:
# download tutorial database
# bkup current database
# move download database into position

ADU_PATH=$(echo ${ARTDAQ_DATABASE_URI} | cut -d':' -f2)
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t artdaq database filesystem URI Path = ${ADU_PATH}"

#attempt to mkdir for full path so that it exists to move the database to
# assuming mkdir is non-destructive
ADU_ARR=$(echo ${ADU_PATH} | tr '/' "\n")
ADU_PATH=""
for ADU_EL in ${ADU_ARR[@]}
do
	#echo $ADU_EL
	#echo $ADU_PATH
	mkdir $ADU_PATH &>/dev/null #hide output
	ADU_PATH="$ADU_PATH/$ADU_EL"
done

# download tutorial user data
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t *****************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Downloading tutorial user data.."
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t git clone https://github.com/art-daq/otsdaq_demo_data -b ${TUTORIAL}"
echo

git clone https://github.com/art-daq/otsdaq_demo_data.git -b ${TUTORIAL}

# bkup current user data
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t *****************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Backing up current user data.."
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t mv ${USER_DATA} ${USER_DATA}.bak`date +%y%m%d`"
echo
mv ${USER_DATA} ${USER_DATA}.bak`date +%y%m%d`

# move download user data into position
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t *****************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Installing tutorial data as user data.."
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t mv otsdaq_demo_data/Data ${USER_DATA}"
echo
mv otsdaq_demo_data/Data ${USER_DATA}

echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t *****************************************************"
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t otsdaq tutorial Data installed!"
echo
echo

# bkup current database
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t *****************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Backing up current database.."
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t mv ${ADU_PATH} ${ADU_PATH}.bak`date +%y%m%d`"
echo
mv ${ADU_PATH} ${ADU_PATH}.bak`date +%y%m%d`

# move download user data into position
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t *****************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Installing tutorial database as database.."
echo 

#hard to be sure of depth of table folders, so check
if [ -d otsdaq_demo_data/databases/XDAQContextTable ]; then
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t mv otsdaq_demo_data/databases ${ADU_PATH}"
	mv otsdaq_demo_data/databases ${ADU_PATH}
elif [ -d otsdaq_demo_data/databases/filesystemdb/XDAQContextTable ]; then
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t mv otsdaq_demo_data/databases/filesystemdb ${ADU_PATH}"
	mv otsdaq_demo_data/databases/filesystemdb ${ADU_PATH}
else
	echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t mv otsdaq_demo_data/databases/filesystemdb/test_db ${ADU_PATH}"	
	mv otsdaq_demo_data/databases/filesystemdb/test_db ${ADU_PATH}
fi

echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t *****************************************************"
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t otsdaq tutorial database installed!"
echo
echo

echo
echo
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t Cleaning up downloads.."
echo 
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t rm -rf otsdaq_demo_data"
echo
rm -rf otsdaq_demo_data

exit

#!/bin/bash

# usage: --tutorial <tutorial name> --version <version string>
#
#   tutorial 
#		e.g. ${TUTORIAL} or artdaq
#   version 
#		usually looks like v2_2 to represent v2.2 release, for example 
#		(underscores might more universal for web downloads than periods)
#
#  example run:
#	./get_tutorial_database.sh --tutorial first_demo --version v2_2
#

if ! [ -e setup_ots.sh ]; then
  kdialog --sorry "You must run this script from an OTSDAQ installation directory!"
  exit 1
fi

# Login to redmine
source "${OTSDAQ_DIR}"/tools/redmine_login.sh

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
VERSION='v2_2'

if [[ "$1"  == "--tutorial" && "x$2" != "x" ]]; then
	TUTORIAL="$2"
fi

if [[ "$3"  == "--version" && "x$4" != "x" ]]; then
	VERSION="$4"
fi

echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t TUTORIAL \t= $TUTORIAL"
echo -e `date +"%h%y %T"` "get_tutorial_data.sh [${LINENO}]  \t VERSION  \t= $VERSION"
echo		

shopt -s expand_aliases #allows for aliases in non-interactive mode (which apparently is critical depending on the temperment of the terminal)
source setup_ots.sh

echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t ********************************************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t **** Gettings otsdaq tutorial Database (configuration tables, etc.)... *********"
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t ********************************************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t "


if [ "x$ARTDAQ_DATABASE_URI" == "x" ]; then
	echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t Error."
	echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t Environment variable ARTDAQ_DATABASE_URI not setup!"
	echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t To setup, use 'export ARTDAQ_DATABASE_URI=filesystemdb://<path to database>'" 
	echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t            e.g. filesystemdb:///home/rrivera/databases/filesystemdb/test_db"
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
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t artdaq database filesystem URI Path = ${ADU_PATH}"

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

# download tutorial database
echo 
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t *****************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t Downloading tutorial database.."
echo 
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t wget --load-cookies=$REDMINE_LOGIN_COOKIEF otsdaq.fnal.gov/downloads/tutorial_${TUTORIAL}_${VERSION}_database.zip"
echo

#FIXME -- for now, every tutorial gets same database (until security to zip files can be resolved)
rm -rf tutorial_${TUTORIAL}_${VERSION}_database.zip* >/dev/null 2>&1 # * helps root delete
#NOTE!! must add "download" to link
wget https://cdcvs.fnal.gov/redmine/attachments/download/66045/tutorial_first_demo_v2_5_database.zip \
    --no-check-certificate \
	--load-cookies=${REDMINE_LOGIN_COOKIEF} \
	--save-cookies=${REDMINE_LOGIN_COOKIEF} \
	--keep-session-cookies \
	-O tutorial_${TUTORIAL}_${VERSION}_database.zip
# wget --load-cookies=$cookief otsdaq.fnal.gov/downloads/tutorial_${TUTORIAL}_${VERSION}_database.zip


echo
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t Unzipping tutorial database.."
echo 
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t unzip tutorial_${TUTORIAL}_${VERSION}_database.zip -d tmpd1234"
unzip tutorial_${TUTORIAL}_${VERSION}_database.zip -d tmpd1234

# bkup current database
echo 
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t *****************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t Backing up current database.."
echo 
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t mv ${ADU_PATH} ${ADU_PATH}.bak"
echo
rm -rf ${ADU_PATH}.bak
mv ${ADU_PATH} ${ADU_PATH}.bak

# move download user data into position
echo 
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t *****************************************************"
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t Installing tutorial database as database.."
echo 

#hard to be sure of depth of table folders, so check
if [ -d tmpd1234/databases/XDAQContextTable ]; then
	echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t mv tmpd1234/databases ${ADU_PATH}"
	mv tmpd1234/databases ${ADU_PATH}
elif [ -d tmpd1234/databases/filesystemdb/XDAQContextTable ]; then
	echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t mv tmpd1234/databases/filesystemdb ${ADU_PATH}"
	mv tmpd1234/databases/filesystemdb ${ADU_PATH}
else
	echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t mv tmpd1234/databases/filesystemdb/test_db ${ADU_PATH}"	
	mv tmpd1234/databases/filesystemdb/test_db ${ADU_PATH}
fi

echo
echo
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t Cleaning up downloads.."
echo 
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t rm -rf tmpd1234; rm -rf tutorial_${TUTORIAL}_${VERSION}_database.zip"
echo
rm -rf tmpd1234; rm -rf tutorial_${TUTORIAL}_${VERSION}_database.zip

echo 
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t *****************************************************"
echo 
echo -e `date +"%h%y %T"` "get_tutorial_database.sh [${LINENO}]  \t otsdaq tutorial database installed!"
echo
echo

exit

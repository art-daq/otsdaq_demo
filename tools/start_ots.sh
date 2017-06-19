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

kdialog --yesno "Start OTS?"
if [[ $? -eq 0 ]];then
  StartOTS.sh --wiz #just to test activate the saved groups  
  StartOTS.sh
  google-chrome http://otsdaq:2015/urn:xdaq-application:lid=200#1
else
  kdialog --yesno "Start OTS in Wizard Mode?"
  if [[ $? -eq 0 ]]; then
    StartOTS.sh --wiz
	
	#FIXME get verify code from StartOTS url printout .. or change StartOTS to have an option for launching chrome
    google-chrome http://otsdaq:2015/urn:xdaq-application:lid=290/Verify?code=fa37
  fi
fi


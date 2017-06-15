cd ~/Desktop/otsdaq-v1_01_01/log
source ~/Desktop/otsdaq-v1_01_01/setup_ots.sh
kdialog --yesno "Start OTS in Wizard Mode?"
wizmode=$?
echo "Wizmode is $wizmode"
if [[ $wizmode -eq 0 ]]; then
  StartOTS.sh --wiz
  google-chrome http://otsdaq:2015/urn:xdaq-application:lid=290/Verify?code=fa37
else
  kdialog --yesno "Start OTS?"
  if [[ $? -eq 0 ]];then
    StartOTS.sh
    google-chrome http://otsdaq:2015/urn:xdaq-application:lid=200
  fi
fi


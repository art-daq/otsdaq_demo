#!/bin/sh
echo "********************************************************************************"
echo "************ Gettings otsdaq tutorial Data (user settings, etc.)... ************"
echo "********************************************************************************"
echo ""


if [ "x$USER_DATA" == "x" ]; then
	echo "Error."
	echo "Environment variable USER_DATA not setup!"
	echo "To setup, use 'export USER_DATA=<path to user data>'"
	echo 
	echo
	echo "(If you do not have a user data folder copy '<path to ots source>/otsdaq-demo/Data' as your starting point.)"
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


# download tutorial user data
echo 
echo "*****************************************************"
echo "Downloading tutorial user data.."
echo 
echo "wget otsdaq.fnal.gov/downloads/tutorial_Data_v2.zip"
echo
wget otsdaq.fnal.gov/downloads/tutorial_Data_v2.zip
echo
echo "Unzipping tutorial user data.."
echo 
echo "unzip tutorial_Data_v2.zip -d tmp01234"
unzip tutorial_Data_v2.zip -d tmp01234

# bkup current user data
echo 
echo "*****************************************************"
echo "Backing up current user data.."
echo 
echo "mv ${USER_DATA} ${USER_DATA}.bak"
echo
rm -rf ${USER_DATA}.bak
mv ${USER_DATA} ${USER_DATA}.bak

# move download user data into position
echo 
echo "*****************************************************"
echo "Installing tutorial data as user data.."
echo 
echo "mv tmp01234/NoGitData ${USER_DATA}"
echo
mv tmp01234/NoGitData ${USER_DATA}

echo
echo "Cleaning up downloads.."
echo 
echo "rm -rf tmp01234; rm -rf tutorial_Data_v2.zip"
echo
rm -rf tmp01234; rm -rf tutorial_Data_v2.zip

echo 
echo "*****************************************************"
echo 
echo "otsdaq tutorial Data installed!"
echo
echo

exit

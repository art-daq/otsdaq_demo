#!/bin/sh
echo "********************************************************************************"
echo "**** Gettings otsdaq tutorial Database (configuration tables, etc.)... *********"
echo "********************************************************************************"
echo ""


if [ "x$ARTDAQ_DATABASE_URI" == "x" ]; then
	echo "Error."
	echo "Environment variable ARTDAQ_DATABASE_URI not setup!"
	echo "To setup, use 'export ARTDAQ_DATABASE_URI=filesystemdb://<path to database>'" 
	echo "           e.g. filesystemdb:///home/rrivera/databases/filesystemdb/test_db"
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
echo "artdaq database filesystem URI Path = ${ADU_PATH}"

#attempt to mkdir for full path so that it exists to move the database to
# assuming mkdir is non-destructive
ADU_ARR=$(echo ${ADU_PATH} | tr '/' "\n")
ADU_PATH=""
for ADU_EL in ${ADU_ARR[@]}
do
	#echo $ADU_EL
	#echo $ADU_PATH
	mkdir $ADU_PATH &> null #hide output
	ADU_PATH="$ADU_PATH/$ADU_EL"
done

# download tutorial database
echo 
echo "*****************************************************"
echo "Downloading tutorial database.."
echo 
echo "wget otsdaq.fnal.gov/downloads/tutorial_database_v2.zip"
echo
wget otsdaq.fnal.gov/downloads/tutorial_database_v2.zip
echo
echo "Unzipping tutorial database.."
echo 
echo "unzip tutorial_database_v2.zip -d tmpd1234"
unzip tutorial_database_v2.zip -d tmpd1234

# bkup current database
echo 
echo "*****************************************************"
echo "Backing up current database.."
echo 
echo "mv ${ADU_PATH} ${ADU_PATH}.bak"
echo
mv ${ADU_PATH} ${ADU_PATH}.bak

# move download user data into position
echo 
echo "*****************************************************"
echo "Installing tutorial data as database.."
echo 
echo "mv tmpd1234/databases/filesystemdb/test_db ${ADU_PATH}"
echo
mv tmpd1234/databases/filesystemdb/test_db ${ADU_PATH}

echo
echo "Cleaning up downloads.."
echo 
echo "rm -rf tmpd1234; rm -rf tutorial_database_v2.zip"
echo
rm -rf tmpd1234; rm -rf tutorial_database_v2.zip

echo 
echo "*****************************************************"
echo 
echo "otsdaq tutorial database installed!"
echo
echo

exit
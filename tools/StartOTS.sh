#!/bin/sh
echo "Starting otsdaq..."

ISCONFIG=0

if [[ "$1"  == "--config" || "$1"  == "--configure" || "$1"  == "--wizard" || "$1"  == "--wiz" ]]; then
    echo "*****************************************************"
    echo "*************CONFIGURATION MODE ENABLED!*************"
    echo "*****************************************************"
    ISCONFIG=1
fi

if [[ $ISCONFIG == 0 && "$1x" != "x" ]]; then
	echo 
	echo "Unrecognized paramater $1"
	echo
	echo "To start otsdaq in 'wiz mode' please use any of these options:"
	echo "--config --configure --wizard --wiz"
	echo
	echo "aborting..."
	exit
fi



SERVER=`hostname -f || ifconfig eth0|grep "inet addr"|cut -d":" -f2|awk '{print $1}'`
export SUPERVISOR_SERVER=$SERVER
if [ $ISCONFIG == 1 ]; then
    export OTS_CONFIGURATION_WIZARD_SUPERVISOR_SERVER=$SERVER
fi

 #Can be File, Database, DatabaseTest
export CONFIGURATION_TYPE=File

# Setup environment when building with MRB (As there's no setupARTDAQOTS file)
if [ "x$MRB_BUILDDIR" != "x" ]; then
  export OTSDAQDEMO_BUILD=${MRB_BUILDDIR}/otsdaq_demo
  export OTSDAQ_DEMO_LIB=${MRB_BUILDDIR}/otsdaq_demo/lib
  export OTSDAQDEMO_REPO=$OTSDAQ_DEMO_DIR
  unset OTSDAQ_DEMO_DIR
  export OTSDAQ_BUILD=${MRB_BUILDDIR}/otsdaq
  export OTSDAQ_LIB=${MRB_BUILDDIR}/otsdaq/lib
  export OTSDAQ_REPO=$OTSDAQ_DIR
  export OTSDAQUTILITIES_BUILD=${MRB_BUILDDIR}/otsdaq_utilities
  export OTSDAQ_UTILITIES_LIB=${MRB_BUILDDIR}/otsdaq_utilities/lib
  export OTSDAQUTILITIES_REPO=$OTSDAQ_UTILITIES_DIR
  export FHICL_FILE_PATH=.:$OTSDAQ_REPO/tools/fcl:$FHICL_FILE_PATH
fi

if [ "x$OTSDAQ_DEMO_DIR" == "x" ]; then
  export OTSDAQ_DEMO_DIR=$OTSDAQDEMO_BUILD
fi

if [ "x$USER_WEB_PATH" == "x" ]; then
  export USER_WEB_PATH=$OTSDAQ_DEMO_DIR/WebGUI
fi

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

echo "Environment variable USER_DATA is setup!"
echo "User data folder is at " ${USER_DATA}

export CONFIGURATION_DATA_PATH=${USER_DATA}/ConfigurationDataExamples
export CONFIGURATION_INFO_PATH=${USER_DATA}/ConfigurationInfo
export SERVICE_DATA_PATH=${USER_DATA}/ServiceData
export XDAQ_CONFIGURATION_DATA_PATH=${USER_DATA}/XDAQConfigurations
export LOGIN_DATA_PATH=${USER_DATA}/ServiceData/LoginData
export LOGBOOK_DATA_PATH=${USER_DATA}/ServiceData/LogbookData
export PROGRESS_BAR_DATA_PATH=${USER_DATA}/ServiceData/ProgressBarData
export ROOT_DISPLAY_CONFIG_PATH=${USER_DATA}/RootDisplayConfigData

export ROOT_BROWSER_PATH=${OTSDAQ_DEMO_DIR}

if [ "x$OTSDAQ_LOG_DIR" == "x" ];then
    export OTSDAQ_LOG_DIR="${OTSDAQDEMO_BUILD}/Logs"
fi
if [ "x${ARTDAQ_OUTPUT_DIR}" == "x" ]; then
    export ARTDAQ_OUTPUT_DIR="${OTSDAQDEMO_BUILD}"
fi

if [ ! -d $ARTDAQ_OUTPUT_DIR ]; then
    mkdir -p $ARTDAQ_OUTPUT_DIR
fi

if [ ! -d $OTSDAQ_LOG_DIR ]; then
    mkdir -p $OTSDAQ_LOG_DIR
fi

##############################################################################
export XDAQ_CONFIGURATION_XML=otsConfigurationNoRU_CMake #-> 
##############################################################################

killall -9 mpirun
killall -9 xdaq.exe
killall -9 mf_rcv_n_fwd #message viewer display without decoration

#give time for killall
sleep 1

#echo "ARTDAQ_MFEXTENSIONS_DIR=" ${ARTDAQ_MFEXTENSIONS_DIR}

if [ $ISCONFIG == 1 ]; then

	#setup wiz mode environment variables
	export CONFIGURATION_GUI_SUPERVISOR_ID=280
	export OTS_CONFIGURATION_WIZARD_SUPERVISOR_ID=290	
	MAIN_PORT=2015
	if [ $USER == rrivera ]; then
	  MAIN_PORT=1983
	elif [ $USER == lukhanin ]; then
	  MAIN_PORT=2060
	elif [ $USER == uplegger ]; then
	  MAIN_PORT=1974
	elif [ $USER == parilla ]; then
	   MAIN_PORT=9000
	elif [ $USER == eflumerf ]; then
	   MAIN_PORT=1987
	elif [ $USER == swu ]; then
	   MAIN_PORT=1994
	elif [ $USER == phansen2 ]; then
	   MAIN_PORT=1776
	elif [ $USER == naodell ]; then
	   MAIN_PORT=2030
	elif [ $USER == bschneid ]; then
	   MAIN_PORT=2050
	fi
	export PORT=${MAIN_PORT}
	
	#substitute environment variables into template wiz-mode xdaq config xml
	envsubst <${XDAQ_CONFIGURATION_DATA_PATH}/otsConfigurationNoRU_Wizard_CMake.xml > ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfigurationNoRU_Wizard_CMake_Run.xml

	#use safe Message Facility fcl in config mode
	export OTSDAQ_LOG_FHICL=${USER_DATA}/MessageFacilityConfigurations/MessageFacilityWithCout.fcl
	
	echo ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfigurationNoRU_Wizard_CMake_Run.xml
    xdaq.exe -p ${PORT} -e ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfigurationNoRU_Wizard_CMake_Run.xml &
		
	################
	# start node db server

	#echo "ARTDAQ_UTILITIES_DIR=" ${ARTDAQ_UTILITIES_DIR}
	#cd $ARTDAQ_UTILITIES_DIR/node.js
	#as root, once...
	# chmod +x setupNodeServer.sh 
	# ./setupNodeServer.sh 
	# chown -R products:products *
	
	#uncomment to use artdaq db nodejs web gui
	#node serverbase.js > /tmp/${USER}_serverbase.log &
	
else

	####################################################################
	########### start console & message facility handling ##############
	####################################################################
	#decide which MessageFacility console viewer to run
	# and configure otsdaq MF library with MessageFacility*.fcl to use
	
	export OTSDAQ_LOG_FHICL=${USER_DATA}/MessageFacilityConfigurations/MessageFacilityGen.fcl
	#this fcl tells the MF library used by ots source how to behave
	echo "OTSDAQ_LOG_FHICL=" ${OTSDAQ_LOG_FHICL}
	
	
	USE_WEB_VIEWER="$(cat ${USER_DATA}/MessageFacilityConfigurations/UseWebConsole.bool)"
	USE_QT_VIEWER="$(cat ${USER_DATA}/MessageFacilityConfigurations/UseQTViewer.bool)"
			
	
	echo "USE_WEB_VIEWER" ${USE_WEB_VIEWER}
	echo "USE_QT_VIEWER" ${USE_QT_VIEWER}
	
	
	if [[ $USE_WEB_VIEWER == "1" ]]; then
		echo "Using web console viewer"
		
		#start quiet forwarder with receiving port and destination port parameter file
		mf_rcv_n_fwd ${USER_DATA}/MessageFacilityConfigurations/QuietForwarderGen.cfg  & 	
	fi
	
	if [[ $USE_QT_VIEWER == "1" ]]; then
		echo "Using QT console viewer"
		if [ "x$ARTDAQ_MFEXTENSIONS_DIR" == "x" ]; then #qtviewer library missing!
			echo
			echo "Error: ARTDAQ_MFEXTENSIONS_DIR missing for qtviewer!"
			echo
			exit
		fi
		
		#start the QT Viewer (only if it is not already started)
		if [ $( ps aux|egrep -c $USER.*msgviewer ) -eq 1 ]; then				
			msgviewer -c ${USER_DATA}/MessageFacilityConfigurations/QTMessageViewerGen.fcl  &
			sleep 2		
		fi		
	fi
	
	####################################################################
	########### end console & message facility handling ################
	####################################################################
	
	
	# kill node db server (only allowed in wiz mode)
	# search assuming port 8080
	# netstat -apn | grep node | grep 8080 | grep LISTEN | rev | cut -d'.' -f1 | cut -c 16-22 | rev
	# kill result
	NODESERVERPS="$(netstat -apn | grep node | grep 8080 | grep LISTEN | rev | cut -d'.' -f1 | cut -c 16-22 | rev)"
	kill -9 $NODESERVERPS
			
    envString="-genv OTSDAQ_LOG_ROOT ${OTSDAQ_LOG_DIR} -genv ARTDAQ_OUTPUT_DIR ${ARTDAQ_OUTPUT_DIR}"
	
    echo "XDAQ Configuration XML:"
	echo ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}.xml
	export XDAQ_ARGS="${XDAQ_CONFIGURATION_DATA_PATH}/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}.xml"
	echo
	echo ${XDAQ_ARGS}
	echo
	echo
	
	#xdaq run
	killall StartXDAQ_gen.sh
	echo "xdaq call:"
	chmod 755 ${USER_DATA}/XDAQConfigurations/StartXDAQ_gen.sh
	echo "${USER_DATA}/XDAQConfigurations/StartXDAQ_gen.sh &"
	echo
	#xdaq.exe -p ${PORT} -e ${XDAQ_ARGS} &
	${USER_DATA}/XDAQConfigurations/StartXDAQ_gen.sh &   
	
	#mpi run
	killall StartMPI_gen.sh
	echo "mpi call:"
	chmod 755 ${USER_DATA}/XDAQConfigurations/StartMPI_gen.sh
	echo "${USER_DATA}/XDAQConfigurations/StartMPI_gen.sh $envString &"
	echo 
	${USER_DATA}/XDAQConfigurations/StartMPI_gen.sh "$envString" &                                                                                                                         
fi

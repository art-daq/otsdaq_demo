#!/bin/sh
echo "Correct Script"

ISCONFIG=0
USEVIEWER=0

if [[ "$1"  == "--config" ]]; then
    echo "*****************************************************"
    echo "*************CONFIGURATION MODE ENABLED!*************"
    echo "*****************************************************"
    ISCONFIG=1
fi
if [[ "$1" == "--viewer" ]]; then
   USEVIEWER=1
fi


export SUPERVISOR_ID=200
export FEW_SUPERVISOR_ID=210
export FER_SUPERVISOR_ID=220
export FEWR_SUPERVISOR_ID=225
export ARTDAQ_BUILDER_SUPERVISOR_ID=230
export ARTDAQ_AGGREGATOR_SUPERVISOR_ID=240
export CHAT_SUPERVISOR_ID=250
export LOGBOOK_SUPERVISOR_ID=260
export VISUAL_SUPERVISOR_ID=270
export CONFIGURATION_GUI_SUPERVISOR_ID=280
export ARTDAQ_FE_DATA_MANAGER_SUPERVISOR_ID=320
export ARTDAQ_DATA_MANAGER_SUPERVISOR_ID=330
if [ $ISCONFIG == 1 ]; then
    export OTS_CONFIGURATION_WIZARD_SUPERVISOR_ID=290
fi
export MACROMAKER_SUPERVISOR_ID=300
export DATA_MANAGER_SUPERVISOR_ID=310

MAIN_PORT=2015
if [ $USER == rrivera ]; then
  MAIN_PORT=1983
elif [ $USER == uplegger ]; then
  MAIN_PORT=1974
elif [ $USER == parilla ]; then
   MAIN_PORT=1997
elif [ $USER == eflumerf ]; then
   MAIN_PORT=1987
elif [ $USER == swu ]; then
   MAIN_PORT=1994
elif [ $USER == phansen2 ]; then
   MAIN_PORT=1776
elif [ $USER == naodell ]; then
   MAIN_PORT=2030
elif [ $USER == ajay ]; then
   MAIN_PORT=2040
elif [ $USER == bschneid ]; then
   MAIN_PORT=2050
fi

export PORT=${MAIN_PORT}
export ARTDAQ_BUILDER_PORT=`expr $MAIN_PORT + 1`
export ARTDAQ_AGGREGATOR_PORT=`expr $MAIN_PORT + 2`
export ARTDAQ_BOARDREADER_PORT=`expr $MAIN_PORT + 3`
#export ARTDAQ_BOARDREADER_PORT1=`expr $MAIN_PORT + 3`
#export ARTDAQ_BOARDREADER_PORT2=`expr $MAIN_PORT + 4`

SERVER=`hostname -f || ifconfig eth0|grep "inet addr"|cut -d":" -f2|awk '{print $1}'`
export SUPERVISOR_SERVER=$SERVER
export FEW_SUPERVISOR_SERVER=$SERVER
export FER_SUPERVISOR_SERVER=$SERVER
export ARTDAQ_BUILDER_SUPERVISOR_SERVER=$SERVER
export ARTDAQ_AGGREGATOR_SUPERVISOR_SERVER=$SERVER
export CHAT_SUPERVISOR_SERVER=$SERVER
export LOGBOOK_SUPERVISOR_SERVER=$SERVER
export VISUAL_SUPERVISOR_SERVER=$SERVER
export CONFIGURATION_GUI_SUPERVISOR_SERVER=$SERVER
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

if [ "x$USER_DATA" == "x" ]; then
    export USER_DATA=${OTSDAQ_DEMO_DIR}/Data
fi
echo "User data folder is at " ${USER_DATA}

export CONFIGURATION_DATA_PATH=${USER_DATA}/ConfigurationDataExamples
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

export XDAQ_CONFIGURATION_XML=otsConfigurationNoRU_CMake
#export XDAQ_CONFIGURATION_XML=otsConfigurationNoRU_CMake_AllPlanes
#export XDAQ_CONFIGURATION_XML=otsConfigurationNoRU_CMake_AllCMSWorld


envsubst <${XDAQ_CONFIGURATION_DATA_PATH}/otsConfigurationNoRU_Wizard_CMake.xml > ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfigurationNoRU_Wizard_CMake_Run.xml
envsubst <${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}.xml > ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}_Run.xml
#envsubst <${XDAQ_CONFIGURATION_DATA_PATH}/otsConfigurationNoARTDAQRU_CMake.xml > ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfigurationNoARTDAQRU_CMake_Run.xml

killall -9 mpirun
killall -9 xdaq.exe
sleep 1

#xdaq.exe -p ${PORT} -e ${OTSDAQ_DEMO_DIR}/Data/XDAQConfigurations/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_XML} &
if [ $ISCONFIG == 1 ]; then
    xdaq.exe -p ${PORT} -e ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfigurationNoRU_Wizard_CMake_Run.xml &
else
    envString="-genv OTSDAQ_LOG_ROOT ${OTSDAQ_LOG_DIR} -genv ARTDAQ_OUTPUT_DIR ${ARTDAQ_OUTPUT_DIR}"
    if [ "x$ARTDAQ_MFEXTENSIONS_DIR" != "x"  -a $USEVIEWER -eq 1 ]; then
        export OTSDAQ_LOG_FHICL=${OTSDAQ_DEMO_DIR}/fcl/MessageFacility.fcl
        msgviewer -c ${OTSDAQ_DEMO_DIR}/fcl/msgviewer.fcl >/dev/null 2>&1 & 
	sleep 2
    fi
    echo ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}_Run.xml
    xdaq.exe -p ${PORT} -e ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}_Run.xml & 
    mpirun $envString \
       -np 1 xdaq.exe -p ${ARTDAQ_BOARDREADER_PORT} -e ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}_Run.xml : \
       -np 1 xdaq.exe -p ${ARTDAQ_BUILDER_PORT}     -e ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}_Run.xml : \
       -np 1 xdaq.exe -p ${ARTDAQ_AGGREGATOR_PORT}  -e ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}_Run.xml &
   #echo xdaq.exe -p ${PORT}  -e ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}_Run.xml
   #xdaq.exe -p ${PORT}  -e ${XDAQ_CONFIGURATION_DATA_PATH}/otsConfiguration_CMake.xml -c ${XDAQ_CONFIGURATION_DATA_PATH}/${XDAQ_CONFIGURATION_XML}_Run.xml
fi

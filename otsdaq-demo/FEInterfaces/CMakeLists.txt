include_directories(${MPI_INCLUDE_PATH})
include_directories(${CMAKE_BINARY_DIR}/artdaq)
  
simple_plugin(FEOtsEthernetProgramInterface "interface"
	otsdaq_components::otsdaq-components_FEInterfaces_FEOtsUDPTemplateInterface_interface
  otsdaq_components::DAQHardware
  otsdaq::FECore
  otsdaq::Configurable
  otsdaq::WorkLoopManager
#  MessageFacility
   otsdaq::Macros
  otsdaq::NetworkUtilities
  otsdaq::ConfigurationInterface
  otsdaq::TableCore
#  otsdaq-demo_FEInterfaces_FEOtsUDPTemplateInterface_interface
#  ${CETLIB}
#  ${CETLIB_EXCEPT}
	${MF_MESSAGELOGGER}
	${XDAQ_XERCES-C}
	${Boost_SYSTEM_LIBRARY}
	pthread
  )
  

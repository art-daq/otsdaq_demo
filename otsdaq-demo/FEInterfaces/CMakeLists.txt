  
basic_plugin(FEOtsEthernetProgramInterface "interface"
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
#  cetlib
#  cetlib_except
	MF_MessageLogger
	${XDAQ_XERCES-C}
	${Boost_SYSTEM_LIBRARY}
	pthread
  )
  

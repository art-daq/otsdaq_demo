include_directories(${MPI_INCLUDE_PATH})
include_directories(${CMAKE_BINARY_DIR}/artdaq)

#cet_make(LIBRARY_NAME FEInterfaces
#		 LIBRARIES
#         FECore		 
#         ${CETLIB}
#)
#
#install_headers()
#install_source()

  
simple_plugin(FEOtsUDPTemplateInterface "interface"
  DAQHardware
  FECore
  WorkLoopManager
  MessageFacility
  NetworkUtilities
  ConfigurationInterface
  ConfigurationDataFormats
  $ENV{XERCES_C_LIB}/libxerces-c.so
  ${CETLIB}
  ${CETLIB_EXCEPT}
  )
    
#simple_plugin(myNewInterface "interface"
#  DAQHardware
#  FECore
#  WorkLoopManager
#  MessageFacility
#  NetworkUtilities
#  ConfigurationInterface
#  ConfigurationDataFormats
#  $ENV{XERCES_C_LIB}/libxerces-c.so
#  ${CETLIB}
#  ${CETLIB_EXCEPT}
#  )
  
simple_plugin(FEOtsEthernetProgramInterface "interface"
  DAQHardware
  FECore
  WorkLoopManager
  MessageFacility
  NetworkUtilities
  ConfigurationInterface
  ConfigurationDataFormats
  otsdaq-demo_FEInterfaces_FEOtsUDPTemplateInterface_interface
  $ENV{XERCES_C_LIB}/libxerces-c.so
  ${CETLIB}
  ${CETLIB_EXCEPT}
  )
  
#simple_plugin(FEPurduePSI46DigInterface "interface"
#  otsdaq-demo_UserConfigurationDataFormats_FEWOtsUDPHardwareConfiguration_configuration
#  DAQHardware
#  FECore
#  ${CETLIB}
#  )
  
#simple_plugin(FEPurdueVIPICInterface "interface"
#  otsdaq-demo_UserConfigurationDataFormats_FEWOtsUDPHardwareConfiguration_configuration
#  DAQHardware
#  FECore
#  ${CETLIB}
#  )
  
#simple_plugin(FEZEDRyanInterface "interface"
#  otsdaq-demo_UserConfigurationDataFormats_FEWOtsUDPHardwareConfiguration_configuration
#  DAQHardware
#  FECore
#  ${CETLIB}
#  )
 

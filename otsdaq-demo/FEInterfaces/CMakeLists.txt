
include(otsdaq::FEInterface)
  
cet_build_plugin(FEOtsEthernetProgramInterface otsdaq::FEInterface LIBRARIES REG otsdaq_components::FEOtsUDPTemplateInterface )
  

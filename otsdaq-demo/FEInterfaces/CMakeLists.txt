
include(otsdaq::FEInterface)

cet_build_plugin(FEOtsEthernetProgramInterface otsdaq::FEInterface LIBRARIES REG otsdaq-components::FEOtsUDPTemplateInterface )


install_headers()
install_source()

include(BuildPlugins) # Art Module
cet_build_plugin(ODWFViewer art::module LIBRARIES REG otsdaq_demo::Overlays ROOT::Core ROOT::Gui otsdaq::MessageFacility)

install_headers()
install_source()
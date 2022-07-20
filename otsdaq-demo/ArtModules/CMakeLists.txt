include(BuildPlugins) # Art Module
cet_build_plugin(WFViewer art::module LIBRARIES REG otsdaq_demo::Overlays ROOT::Core ROOT::Gui otsdaq::MessageFacility)
cet_make_library(LIBRARY_NAME Overlays
SOURCE FragmentType.cc
LIBRARIES PUBLIC
artdaq_core::artdaq-core_Data
       )
       
include(ArtdaqCorePlugins)
cet_build_plugin(OtsDemo artdaq::fragmentNameHelper LIBRARIES REG otsdaq_demo::Overlays)

install_headers()
install_source()

cet_make_library(
SOURCE FragmentType.cc
LIBRARIES PUBLIC
artdaq-core::Data
       )

include(ArtdaqCorePlugins)
cet_build_plugin(OtsDemo artdaq::fragmentNameHelper LIBRARIES REG otsdaq-demo::Overlays)

install_headers()
install_source()

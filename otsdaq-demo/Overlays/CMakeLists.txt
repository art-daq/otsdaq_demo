art_make(LIBRARY_NAME otsdaq-demo_Overlays
    EXCLUDE OtsDemo_fragmentNameHelper.cc
       LIB_LIBRARIES
       artdaq_core::artdaq-core_Data
       )

  basic_plugin(OtsDemo "fragmentNameHelper"
  otsdaq-demo_Overlays
  artdaq_core::artdaq-core_Data_Artdaq_fragmentNameHelper
)
install_headers()
install_source()

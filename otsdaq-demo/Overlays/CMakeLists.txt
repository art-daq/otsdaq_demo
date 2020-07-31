art_make(LIBRARY_NAME otsdaq-demo_Overlays
    EXCLUDE OtsDemo_fragmentNameHelper.cc
       LIB_LIBRARIES
       ${ARTDAQ_DAQDATA}
       ${CETLIB}
       )

  basic_plugin(OtsDemo "fragmentNameHelper"
  artdaq-core_Data
  otsdaq-demo_Overlays
  artdaq-core_Data_Artdaq_fragmentNameHelper
  MF_MessageLogger
)
install_headers()
install_source()

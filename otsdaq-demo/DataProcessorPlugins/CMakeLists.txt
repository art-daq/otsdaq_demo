
include(otsdaq::dataProcessor)
cet_build_plugin(DemoDQMHistosConsumer otsdaq::dataProcessor LIBRARIES REG
	otsdaq_demo::DemoRootUtilities
    otsdaq::RootUtilities
  )
  
install_headers()
install_source()

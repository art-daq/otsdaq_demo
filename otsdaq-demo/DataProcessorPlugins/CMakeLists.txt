simple_plugin(DemoDQMHistosConsumer "processor"
	DemoRootUtilities
    RootUtilities
    DataManager
    WorkLoopManager
    ConfigurationInterface
    ConfigurationDataFormats
	${ROOT_BASIC_LIB_LIST}
  )

install_headers()
install_source()

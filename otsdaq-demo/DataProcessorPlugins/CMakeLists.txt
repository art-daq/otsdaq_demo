simple_plugin(DemoDQMHistosConsumer "processor"
	DemoRootUtilities
    RootUtilities
    DataManager
    WorkLoopManager
	MessageFacility
    ConfigurationInterface
    ConfigurationDataFormats
	${ROOT_BASIC_LIB_LIST}
	${MF_MESSAGELOGGER}
  )

install_headers()
install_source()

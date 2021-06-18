link_directories($ENV{XDAQ_LIB})

cet_make_exec(DemoInterfaceTestMain
  LIBRARIES
		otsdaq_components::otsdaq-components_FEInterfaces_FEOtsUDPTemplateInterface_interface
		
)

install_headers()
install_source()

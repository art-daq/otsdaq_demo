
cet_make_exec(NAME DemoInterfaceTestMain
SOURCE DemoInterfaceTestMain.cc
  LIBRARIES PRIVATE
		otsdaq_components::FEOtsUDPTemplateInterface
)

install_headers()
install_source()

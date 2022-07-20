cet_make_library(LIBRARY_NAME DemoRootUtilities
SOURCE DemoDQMHistos.cc
	      LIBRARIES PRIVATE
		  ROOT::Gui
)

install_headers()
install_source()

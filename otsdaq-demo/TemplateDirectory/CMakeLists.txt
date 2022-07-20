cet_make_library(LIBRARY_NAME TemplateDirectory
SOURCE TemplateSupervisor.cc
		 LIBRARIES PRIVATE
		 otsdaq::CoreSupervisors
		 otsdaq_components::FEInterfaces
)

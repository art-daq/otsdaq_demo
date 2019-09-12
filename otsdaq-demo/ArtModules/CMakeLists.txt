simple_plugin(WFViewer "module" 
	otsdaq-demo_Overlays 
  ${ROOT_CORE}
	${ROOT_GPAD}
	${ROOT_HIST} 
	${ROOT_GUI} 
	${ROOT_RIO}
	MessageFacility
	${MF_MESSAGELOGGER}
	${MF_UTILITIES}
  artdaq-core_Utilities
  rt
)

simple_plugin(OtsInput "source"
  otsdaq-demo_Overlays
  artdaq-core_Core
  artdaq-core_Utilities
  rt
  artdaq_DAQdata
  artdaq-utilities_Plugins
  artdaq_ArtModules
  art_Framework_Core
  art_Framework_IO_Sources
  art_Framework_Principal
  art_Persistency_Provenance
  art_Utilities
  MF_MessageLogger
  ${CETLIB_EXCEPT}
)


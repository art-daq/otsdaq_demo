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
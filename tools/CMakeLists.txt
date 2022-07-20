cet_script( ALWAYS_COPY
    #quick-start.sh
    #installArtDaqOts.sh
    #StartOTS.sh
    multi_udp_send_artdaq.py
    udp_send_artdaq.py
    )

install_fhicl(SUBDIRS fcl)

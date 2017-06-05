#!/bin/tcsh

/usr/bin/nedit-server ConfigurationAliases/0/ConfigurationAliases_v0.xml
/usr/bin/nedit-server Configurations/0/Configurations_v0.xml

if ($#argv == 0) then
/usr/bin/nedit-server FSSRDACsConfiguration/0/FSSRDACsConfiguration_v0.xml
/usr/bin/nedit-server DetectorConfiguration/0/DetectorConfiguration_v0.xml
/usr/bin/nedit-server FEConfiguration/0/FEConfiguration_v0.xml
/usr/bin/nedit-server OtsUDPFEWConfiguration/0/OtsUDPFEWConfiguration_v0.xml
/usr/bin/nedit-server OtsUDPFERConfiguration/0/OtsUDPFERConfiguration_v0.xml
/usr/bin/nedit-server MaskConfiguration/0/MaskConfiguration_v0.xml
/usr/bin/nedit-server DetectorToFEConfiguration/0/DetectorToFEConfiguration_v0.xml
/usr/bin/nedit-server DataManagerConfiguration/0/DataManagerConfiguration_v0.xml
else if($#argv == 1) then
    if($argv[1] == 1) then
	/usr/bin/nedit-server FSSRDACsConfiguration/1/FSSRDACsConfiguration_v1.xml
	/usr/bin/nedit-server DetectorConfiguration/1/DetectorConfiguration_v1.xml
	/usr/bin/nedit-server FEConfiguration/1/FEConfiguration_v1.xml
	/usr/bin/nedit-server OtsUDPFEWConfiguration/1/OtsUDPFEWConfiguration_v1.xml
	/usr/bin/nedit-server OtsUDPFERConfiguration/1/OtsUDPFERConfiguration_v1.xml
	/usr/bin/nedit-server MaskConfiguration/1/MaskConfiguration_v1.xml
	/usr/bin/nedit-server DetectorToFEConfiguration/1/DetectorToFEConfiguration_v1.xml
	/usr/bin/nedit-server DataManagerConfiguration/1/DataManagerConfiguration_v1.xml
    else if($argv[1] == 2) then
	/usr/bin/nedit-server FSSRDACsConfiguration/2/FSSRDACsConfiguration_v2.xml
	/usr/bin/nedit-server DetectorConfiguration/2/DetectorConfiguration_v2.xml
	/usr/bin/nedit-server FEConfiguration/2/FEConfiguration_v2.xml
	/usr/bin/nedit-server OtsUDPFEWConfiguration/2/OtsUDPFEWConfiguration_v2.xml
	/usr/bin/nedit-server OtsUDPFERConfiguration/2/OtsUDPFERConfiguration_v2.xml
	/usr/bin/nedit-server MaskConfiguration/2/MaskConfiguration_v2.xml
	/usr/bin/nedit-server DetectorToFEConfiguration/2/DetectorToFEConfiguration_v2.xml
	/usr/bin/nedit-server DataManagerConfiguration/2/DataManagerConfiguration_v2.xml
    else if($argv[1] == 3) then
	/usr/bin/nedit-server FSSRDACsConfiguration/3/FSSRDACsConfiguration_v3.xml
	/usr/bin/nedit-server DetectorConfiguration/3/DetectorConfiguration_v3.xml
	/usr/bin/nedit-server FEConfiguration/3/FEConfiguration_v3.xml
	/usr/bin/nedit-server OtsUDPFEWConfiguration/3/OtsUDPFEWConfiguration_v3.xml
	/usr/bin/nedit-server OtsUDPFERConfiguration/3/OtsUDPFERConfiguration_v3.xml
	/usr/bin/nedit-server MaskConfiguration/3/MaskConfiguration_v3.xml
	/usr/bin/nedit-server DetectorToFEConfiguration/3/DetectorToFEConfiguration_v3.xml
	/usr/bin/nedit-server DataManagerConfiguration/3/DataManagerConfiguration_v3.xml
    endif
endif

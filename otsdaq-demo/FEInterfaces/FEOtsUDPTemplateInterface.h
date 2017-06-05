#ifndef _ots_FEOtsUDPTemplateInterface_h_
#define _ots_FEOtsUDPTemplateInterface_h_

#include "otsdaq-core/FECore/FEVInterface.h"
#include "otsdaq-components/DAQHardware/OtsUDPHardware.h"
#include "otsdaq-components/DAQHardware/OtsUDPFirmware.h"

#include <string>

namespace ots
{

class FEOtsUDPTemplateInterface : public FEVInterface, public OtsUDPHardware, public OtsUDPFirmware
{

public:
	//FEOtsUDPTemplateInterface     (unsigned int name=0, std::string daqHardwareType="daqHardwareType",	std::string firmwareType="firmwareType", const FEInterfaceConfigurationBase* configuration=0);
	FEOtsUDPTemplateInterface     (const std::string& interfaceUID, const ConfigurationTree& theXDAQContextConfigTree, const std::string& interfaceConfigurationPath);
	virtual ~FEOtsUDPTemplateInterface(void);

	void configure        	(void);
	void halt             	(void);
	void pause            	(void);
	void resume           	(void);
	void start            	(std::string runNumber) override;
	void stop             	(void);
	bool running   		  	(void);

	int universalRead	  	(char* address, char* readValue) override;
	void universalWrite	  	(char* address, char* writeValue) override;

    //void configureFEW     (void);
    //void configureDetector(const DACStream& theDACStream);

private:
	void runSequenceOfCommands(const std::string &treeLinkName);
};

}

#endif

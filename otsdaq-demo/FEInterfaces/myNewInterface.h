#ifndef _ots_myNewInterface_h_
#define _ots_myNewInterface_h_

#include "otsdaq-core/FECore/FEVInterface.h"
#include "otsdaq-components/DAQHardware/OtsUDPHardware.h"
#include "otsdaq-components/DAQHardware/OtsUDPFirmwareDataGen.h"

#include <string>

namespace ots
{

class myNewInterface : public FEVInterface, public OtsUDPHardware, public OtsUDPFirmwareDataGen
{

public:
	//myNewInterface     (unsigned int name=0, std::string daqHardwareType="daqHardwareType",	std::string firmwareType="firmwareType", const FEInterfaceConfigurationBase* configuration=0);
	myNewInterface     		(const std::string& interfaceUID, const ConfigurationTree& theXDAQContextConfigTree, const std::string& interfaceConfigurationPath);
	virtual ~myNewInterface	(void);

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
	//void configureDetector	(const DACStream& theDACStream);

	void testFunction		(frontEndMacroInArgs_t argsIn, frontEndMacroOutArgs_t argsOut);

private:
};

}

#endif

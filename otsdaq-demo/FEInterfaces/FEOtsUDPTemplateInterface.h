#ifndef _ots_FEOtsUDPTemplateInterface_h_
#define _ots_FEOtsUDPTemplateInterface_h_

#include "otsdaq-core/FECore/FEVInterface.h"
#include "otsdaq-components/DAQHardware/OtsUDPHardware.h"
#include "otsdaq-components/DAQHardware/OtsUDPFirmwareDataGen.h"

#include <string>

namespace ots
{

class FEOtsUDPTemplateInterface	: public FEVInterface, public OtsUDPHardware, public OtsUDPFirmwareDataGen
{

public:
	//FEOtsUDPTemplateInterface     (unsigned int name=0, std::string daqHardwareType="daqHardwareType",	std::string firmwareType="firmwareType", const FEInterfaceConfigurationBase* configuration=0);
	FEOtsUDPTemplateInterface     (const std::string& interfaceUID, const ConfigurationTree& theXDAQContextConfigTree, const std::string& interfaceConfigurationPath);
	virtual ~FEOtsUDPTemplateInterface(void);

	void configure        	(void) override;
	void halt             	(void) override;
	void pause            	(void) override;
	void resume           	(void) override;
	void start            	(std::string runNumber) override;
	void stop             	(void) override;
	bool running   		  	(void) override;

	virtual int universalRead	  	(char* address, char* readValue) override;
	virtual void universalWrite	  	(char* address, char* writeValue) override;

	//void configureFEW     (void);
	//void configureDetector(const DACStream& theDACStream);

private:
	void runSequenceOfCommands(const std::string &treeLinkName);
};

}

#endif

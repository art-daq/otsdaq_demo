#include "otsdaq-demo/FEInterfaces/FEOtsUDPTemplateInterface.h"
#include "otsdaq-core/MessageFacility/MessageFacility.h"
#include "otsdaq-core/Macros/CoutHeaderMacros.h"
#include "otsdaq-core/Macros/InterfacePluginMacros.h"
#include <iostream>
#include <set>

using namespace ots;

#undef 	__MF_SUBJECT__
#define __MF_SUBJECT__ "FE-FEOtsUDPTemplateInterface"

//========================================================================================================================
//FEOtsUDPTemplateInterface::FEOtsUDPTemplateInterface(unsigned int name,
//		std::string daqHardwareType, std::string firmwareType, const FEWConfiguration* configuration)
//:Socket            (theConfiguration_->getInterfaceIPAddress(name), theConfiguration_->getInterfacePort(name))
//,FEVInterface     (name,daqHardwareType,firmwareType,configuration)
//,OtsUDPHardware    (theConfiguration_->getIPAddress(name), theConfiguration_->getPort(name))
//,FSSRFirmware      (theConfiguration_->getFirmwareVersion(name), "PurdueFirmwareCore")
//,theConfiguration_ ((FEWOtsUDPHardwareConfiguration*)configuration)
//
//{
//    __MOUT__ << __PRETTY_FUNCTION__ << "Few name: " << name
//    << " Interface IP: "   << theConfiguration_->getInterfaceIPAddress(name)
//    << " Interface Port: " << theConfiguration_->getInterfacePort(name)
//    << " IP: "             << theConfiguration_->getIPAddress(name)
//    << " Port: "           << theConfiguration_->getPort(name)
//    << std::endl;
//}
//========================================================================================================================
FEOtsUDPTemplateInterface::FEOtsUDPTemplateInterface(const std::string& interfaceUID, const ConfigurationTree& theXDAQContextConfigTree, const std::string& interfaceConfigurationPath)
: Socket            (
		theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("HostIPAddress").getValue<std::string>()
		, theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("HostPort").getValue<unsigned int>())
, FEVInterface      (interfaceUID, theXDAQContextConfigTree, interfaceConfigurationPath)
, OtsUDPHardware    (theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("InterfaceIPAddress").getValue<std::string>()
		, theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("InterfacePort").getValue<unsigned int>())
, OtsUDPFirmware    (theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("FirmwareVersion").getValue<unsigned int>(), "OtsFirmwareCore")
{
//    __MOUT__ << "FE name: " << interfaceUID << std::endl;
//    __MOUT__ << " Interface IP: "   << FEVInterface::theXDAQContextConfigTree_.getNode(interfaceConfigurationPath).getNode("IPAddress").getValue<std::string>() << std::endl;
//    __MOUT__ << " Interface Port: " << FEVInterface::theXDAQContextConfigTree_.getNode(interfaceConfigurationPath).getNode("Port").getValue<std::string>() << std::endl;
//    __MOUT__ << " IP: "             << FEVInterface::theXDAQContextConfigTree_.getNode(interfaceConfigurationPath).getNode("IP").getValue<std::string>() << std::endl;
//    __MOUT__ << " Port: "           << FEVInterface::theXDAQContextConfigTree_.getNode(interfaceConfigurationPath).getNode("IPAddress").getValue<std::string>() << std::endl;
	universalAddressSize_ = 8;
	universalDataSize_    = 8;
}

//========================================================================================================================
FEOtsUDPTemplateInterface::~FEOtsUDPTemplateInterface(void)
{}


//========================================================================================================================
void FEOtsUDPTemplateInterface::runSequenceOfCommands(const std::string &treeLinkName)
{
	std::map<uint64_t,uint64_t> writeHistory;
	uint64_t writeAddress, writeValue, bitMask;
	uint8_t bitPosition;

	std::string writeBuffer;
	std::string readBuffer;
	char msg[1000];
	try
	{
		auto configSeqLink = theXDAQContextConfigTree_.getNode(theConfigurationPath_).getNode(treeLinkName);

		if(configSeqLink.isDisconnected())
			__MOUT__ << "Disconnected configure sequence" << std::endl;
		else
		{
			__MOUT__ << "Handling configure sequence." << std::endl;
			auto childrenMap = configSeqLink.getChildrenMap();
			for(const auto &child:childrenMap)
			{
				//WriteAddress and WriteValue fields

				writeAddress = child.second.getNode("WriteAddress").getValue<uint64_t>();
				writeValue = child.second.getNode("WriteValue").getValue<uint64_t>();
				bitPosition = child.second.getNode("StartingBitPosition").getValue<uint8_t>();
				bitMask = (1 << child.second.getNode("BitFieldSize").getValue<uint8_t>())-1;

				writeValue &= bitMask;
				writeValue <<= bitPosition;
				bitMask = ~(bitMask<<bitPosition);

				//place into write history
				if(writeHistory.find(writeAddress) == writeHistory.end())
					writeHistory[writeAddress] = 0;//init to 0

				writeHistory[writeAddress] &= bitMask; //clear incoming bits
				writeHistory[writeAddress] |= writeValue; //add incoming bits

				sprintf(msg,"\t Writing %s: \t %ld(0x%lX) \t %ld(0x%lX)", child.first.c_str(),
						writeAddress, writeAddress,
						writeHistory[writeAddress], writeHistory[writeAddress]);
				__MOUT__ << msg << std::endl;

				writeBuffer.resize(0);
				OtsUDPFirmware::write(writeBuffer, writeAddress, writeHistory[writeAddress]);
				OtsUDPHardware::write(writeBuffer);
//				writeBuffer.resize(0);
//				OtsUDPFirmware::read(writeBuffer, writeAddress);
//				OtsUDPHardware::read(writeBuffer,readBuffer);
			}
		}
	}
	catch(const std::runtime_error &e)
	{
		__MOUT__ << "Error accessing sequence, so giving up:\n" << e.what() << std::endl;
	}
	catch(...)
	{
		__MOUT__ << "Unknown Error accessing sequence, so giving up." << std::endl;
	}
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::configure(void)
{
	__MOUT__ << "configure" << std::endl;
	__MOUT__ << "Clearing receive socket buffer: " << OtsUDPHardware::clearReadSocket() << " packets cleared." << std::endl;

	std::string writeBuffer;
	std::string readBuffer;

	__MOUT__ << "Setting Destination IP: " <<
			theXDAQContextConfigTree_.getNode(theConfigurationPath_).getNode("StreamToIPAddress").getValue<std::string>()
			<< std::endl;
	__MOUT__ << "And Destination Port: " <<
			theXDAQContextConfigTree_.getNode(theConfigurationPath_).getNode("StreamToPort").getValue<unsigned int>()
			<< std::endl;

	writeBuffer.resize(0);
	OtsUDPFirmware::setupBurstDestination(writeBuffer,
			theXDAQContextConfigTree_.getNode(theConfigurationPath_).getNode("StreamToIPAddress").getValue<std::string>(),
			theXDAQContextConfigTree_.getNode(theConfigurationPath_).getNode("StreamToPort").getValue<uint64_t>()
			);
	OtsUDPHardware::write(writeBuffer);

//
//
	__MOUT__ << "Reading back burst dest MAC/IP/Port: "  << std::endl;
	writeBuffer.resize(0);
	OtsUDPFirmware::readBurstDestinationMAC(writeBuffer);
	OtsUDPHardware::read(writeBuffer,readBuffer);
	writeBuffer.resize(0);
	OtsUDPFirmware::readBurstDestinationIP(writeBuffer);
	OtsUDPHardware::read(writeBuffer,readBuffer);
	writeBuffer.resize(0);
	OtsUDPFirmware::readBurstDestinationPort(writeBuffer);
	OtsUDPHardware::read(writeBuffer,readBuffer);


	writeBuffer.resize(0);
	OtsUDPFirmware::read(writeBuffer,0x5);
	OtsUDPHardware::read(writeBuffer,readBuffer);

	//Run Configure Sequence Commands
	runSequenceOfCommands("LinkToConfigureSequence");

	__MOUT__ << "Done with configuring."  << std::endl;
}

//========================================================================================================================
//void FEOtsUDPTemplateInterface::configureDetector(const DACStream& theDACStream)
//{
//	__MOUT__ << "\tconfigureDetector" << std::endl;
//}

//========================================================================================================================
void FEOtsUDPTemplateInterface::halt(void)
{
	__MOUT__ << "\tHalt" << std::endl;
	stop();
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::pause(void)
{
	__MOUT__ << "\tPause" << std::endl;
	stop();
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::resume(void)
{
	__MOUT__ << "\tResume" << std::endl;
	start("");
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::start(std::string )//runNumber)
{
	__MOUT__ << "\tStart" << std::endl;


	//Run Start Sequence Commands
	runSequenceOfCommands("LinkToStartSequence");

	OtsUDPHardware::write(OtsUDPFirmware::startBurst());
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::stop(void)
{
	__MOUT__ << "\tStop" << std::endl;

	//Run Stop Sequence Commands

	runSequenceOfCommands("LinkToStopSequence");

	OtsUDPHardware::write(OtsUDPFirmware::stopBurst());
}

//========================================================================================================================
bool FEOtsUDPTemplateInterface::running(void)
{
	__MOUT__ << "\running" << std::endl;

	//		//example!
	//		//play with array of 8 LEDs at address 0x1003

//
//	bool flashLEDsWhileRunning = false;
//	if(flashLEDsWhileRunning)
//	{
//		std::string writeBuffer;
//		int state = -1;
//		while(WorkLoop::continueWorkLoop_)
//		{
//			//while running
//			//play with the LEDs at address 0x1003
//
//			++state;
//			if(state < 8)
//			{
//				writeBuffer.resize(0);
//				OtsUDPFirmware::write(writeBuffer, 0x1003,1<<state);
//				OtsUDPHardware::write(writeBuffer);
//			}
//			else if(state%2 == 1 && state < 11)
//			{
//				writeBuffer.resize(0);
//				OtsUDPFirmware::write(writeBuffer, 0x1003, 0xFF);
//				OtsUDPHardware::write(writeBuffer);
//			}
//			else if(state%2 == 0 && state < 11)
//			{
//				writeBuffer.resize(0);
//				OtsUDPFirmware::write(writeBuffer, 0x1003,0);
//				OtsUDPHardware::write(writeBuffer);
//			}
//			else
//				state = -1;
//
//			sleep(1);
//		}
//	}

	return false;
}

//========================================================================================================================
//NOTE: buffer for address must be at least size universalAddressSize_
//NOTE: buffer for returnValue must be max UDP size to handle return possibility
int ots::FEOtsUDPTemplateInterface::universalRead(char *address, char *returnValue)
{
    __MOUT__ << "address size " << universalAddressSize_ << std::endl;

    __MOUT__ << "Request: ";
	for(unsigned int i=0;i<universalAddressSize_;++i)
		printf("%2.2X",(unsigned char)address[i]);
	std::cout << std::endl;

	std::string readBuffer(universalDataSize_,0); //0 fill to correct number of bytes

	//OtsUDPHardware::read(FSSRFirmware::universalRead(address), readBuffer) < 0;
    if(OtsUDPHardware::read(OtsUDPFirmware::universalRead(address), readBuffer) < 0) // data reply
    {
    	__MOUT__ << "Caught it! This is when it's getting time out error" << std::endl;
    	return -1;
    }
    __MOUT__ << "Result SIZE: " << readBuffer.size() << std::endl;
    std::memcpy(returnValue,readBuffer.substr(2).c_str(),universalDataSize_);
    return 0;
}

//========================================================================================================================
//NOTE: buffer for address must be at least size universalAddressSize_
//NOTE: buffer for writeValue must be at least size universalDataSize_
void ots::FEOtsUDPTemplateInterface::universalWrite(char* address, char* writeValue)
{
    __MOUT__ << "address size " << universalAddressSize_ << std::endl;
    __MOUT__ << "data size " << universalDataSize_ << std::endl;
    __MOUT__ << "Sending: ";
    for(unsigned int i=0;i<universalAddressSize_;++i)
    	printf("%2.2X",(unsigned char)address[i]);
	std::cout << std::endl;

    OtsUDPHardware::write(OtsUDPFirmware::universalWrite(address,writeValue)); // data request
}

DEFINE_OTS_INTERFACE(FEOtsUDPTemplateInterface)

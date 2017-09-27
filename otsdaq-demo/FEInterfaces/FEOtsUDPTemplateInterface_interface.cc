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
//    __COUT__ << __PRETTY_FUNCTION__ << "Few name: " << name
//    << " Interface IP: "   << theConfiguration_->getInterfaceIPAddress(name)
//    << " Interface Port: " << theConfiguration_->getInterfacePort(name)
//    << " IP: "             << theConfiguration_->getIPAddress(name)
//    << " Port: "           << theConfiguration_->getPort(name)
//    << std::endl;
//}
//========================================================================================================================
FEOtsUDPTemplateInterface::FEOtsUDPTemplateInterface(const std::string& interfaceUID, const ConfigurationTree& theXDAQContextConfigTree, const std::string& interfaceConfigurationPath)
: Socket               (
		theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("HostIPAddress").getValue<std::string>()
		, theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("HostPort").getValue<unsigned int>())
, FEVInterface         (interfaceUID, theXDAQContextConfigTree, interfaceConfigurationPath)
, OtsUDPHardware       (theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("InterfaceIPAddress").getValue<std::string>()
		, theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("InterfacePort").getValue<unsigned int>())
, OtsUDPFirmwareDataGen(theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("FirmwareVersion").getValue<unsigned int>())
{
	universalAddressSize_ = 8;
	universalDataSize_    = 8;
}

//========================================================================================================================
FEOtsUDPTemplateInterface::~FEOtsUDPTemplateInterface(void)
{}


//========================================================================================================================
//runSequenceOfCommands
//	runs a sequence of write commands from a linked section of the configuration tree
//		based on these fields:
//			- WriteAddress,  WriteValue, StartingBitPosition, BitFieldSize
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
			__COUT__ << "Disconnected configure sequence" << std::endl;
		else
		{
			__COUT__ << "Handling configure sequence." << std::endl;
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
				__COUT__ << msg << std::endl;

				writeBuffer.resize(0);
				OtsUDPFirmwareCore::write(writeBuffer, writeAddress, writeHistory[writeAddress]);
				OtsUDPHardware::write(writeBuffer);
				//				writeBuffer.resize(0);
				//				OtsUDPFirmwareCore::read(writeBuffer, writeAddress);
				//				OtsUDPHardware::read(writeBuffer,readBuffer);
			}
		}
	}
	catch(const std::runtime_error &e)
	{
		__COUT__ << "Error accessing sequence, so giving up:\n" << e.what() << std::endl;
	}
	catch(...)
	{
		__COUT__ << "Unknown Error accessing sequence, so giving up." << std::endl;
	}
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::configure(void)
{
	__COUT__ << "configure" << std::endl;
	__COUT__ << "Clearing receive socket buffer: " << OtsUDPHardware::clearReadSocket() << " packets cleared." << std::endl;

	std::string sendBuffer;
	std::string recvBuffer;

	__COUT__ << "Setting Destination IP: " <<
			theXDAQContextConfigTree_.getNode(theConfigurationPath_).getNode("StreamToIPAddress").getValue<std::string>()
			<< std::endl;
	__COUT__ << "And Destination Port: " <<
			theXDAQContextConfigTree_.getNode(theConfigurationPath_).getNode("StreamToPort").getValue<unsigned int>()
			<< std::endl;

	sendBuffer.resize(0);
	OtsUDPFirmwareCore::setDataDestination(sendBuffer,
			theXDAQContextConfigTree_.getNode(theConfigurationPath_).getNode("StreamToIPAddress").getValue<std::string>(),
			theXDAQContextConfigTree_.getNode(theConfigurationPath_).getNode("StreamToPort").getValue<uint64_t>()
	);
	OtsUDPHardware::write(sendBuffer);

	//
	//
	__COUT__ << "Reading back burst dest MAC/IP/Port: "  << std::endl;
	sendBuffer.resize(0);
	OtsUDPFirmwareCore::readDataDestinationMAC(sendBuffer);
	OtsUDPHardware::read(sendBuffer,recvBuffer);
	sendBuffer.resize(0);
	OtsUDPFirmwareCore::readDataDestinationIP(sendBuffer);
	OtsUDPHardware::read(sendBuffer,recvBuffer);
	sendBuffer.resize(0);
	OtsUDPFirmwareCore::readDataDestinationPort(sendBuffer);
	OtsUDPHardware::read(sendBuffer,recvBuffer);


	sendBuffer.resize(0);
	OtsUDPFirmwareCore::readControlDestinationPort(sendBuffer);
	OtsUDPHardware::read(sendBuffer,recvBuffer);

	//Run Configure Sequence Commands
	runSequenceOfCommands("LinkToConfigureSequence");

	__COUT__ << "Done with configuring."  << std::endl;
}

//========================================================================================================================
//void FEOtsUDPTemplateInterface::configureDetector(const DACStream& theDACStream)
//{
//	__COUT__ << "\tconfigureDetector" << std::endl;
//}

//========================================================================================================================
void FEOtsUDPTemplateInterface::halt(void)
{
	__COUT__ << "\tHalt" << std::endl;
	stop();
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::pause(void)
{
	__COUT__ << "\tPause" << std::endl;
	stop();
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::resume(void)
{
	__COUT__ << "\tResume" << std::endl;
	start("");
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::start(std::string )//runNumber)
{
	__COUT__ << "\tStart" << std::endl;


	//Run Start Sequence Commands
	runSequenceOfCommands("LinkToStartSequence");

	std::string sendBuffer;
	OtsUDPFirmwareCore::startBurst(sendBuffer);
	OtsUDPHardware::write(sendBuffer);
}

//========================================================================================================================
void FEOtsUDPTemplateInterface::stop(void)
{
	__COUT__ << "\tStop" << std::endl;

	//Run Stop Sequence Commands

	runSequenceOfCommands("LinkToStopSequence");

	std::string sendBuffer;
	OtsUDPFirmwareCore::stopBurst(sendBuffer);
	OtsUDPHardware::write(sendBuffer);
}

//========================================================================================================================
bool FEOtsUDPTemplateInterface::running(void)
{
	__COUT__ << "\running" << std::endl;

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
	//				OtsUDPFirmwareCore::write(writeBuffer, 0x1003,1<<state);
	//				OtsUDPHardware::write(writeBuffer);
	//			}
	//			else if(state%2 == 1 && state < 11)
	//			{
	//				writeBuffer.resize(0);
	//				OtsUDPFirmwareCore::write(writeBuffer, 0x1003, 0xFF);
	//				OtsUDPHardware::write(writeBuffer);
	//			}
	//			else if(state%2 == 0 && state < 11)
	//			{
	//				writeBuffer.resize(0);
	//				OtsUDPFirmwareCore::write(writeBuffer, 0x1003,0);
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
	__COUT__ << "address size " << universalAddressSize_ << std::endl;

	__COUT__ << "Request: ";
	for(unsigned int i=0;i<universalAddressSize_;++i)
		printf("%2.2X",(unsigned char)address[i]);
	std::cout << std::endl;

	std::string readBuffer, sendBuffer;
	OtsUDPFirmwareCore::read(sendBuffer,address,1 /*size*/);

	//OtsUDPHardware::read(FSSRFirmware::universalRead(address), readBuffer) < 0;
	try
	{
		OtsUDPHardware::read(sendBuffer, readBuffer); // data reply
	}
	catch(std::runtime_error &e)
	{
		__COUT__ << "Caught it! This is when it's getting time out error" << std::endl;
		__COUT_ERR__ << e.what() << std::endl;
		return -1;
	}

	__COUT__ << "Result SIZE: " << readBuffer.size() << std::endl;
	std::memcpy(returnValue,readBuffer.substr(2).c_str(),universalDataSize_);
	return 0;
}

//========================================================================================================================
//NOTE: buffer for address must be at least size universalAddressSize_
//NOTE: buffer for writeValue must be at least size universalDataSize_
void ots::FEOtsUDPTemplateInterface::universalWrite(char* address, char* writeValue)
{
	__COUT__ << "address size " << universalAddressSize_ << std::endl;
	__COUT__ << "data size " << universalDataSize_ << std::endl;
	__COUT__ << "Sending: ";
	for(unsigned int i=0;i<universalAddressSize_;++i)
		printf("%2.2X",(unsigned char)address[i]);
	std::cout << std::endl;

	std::string sendBuffer;
	OtsUDPFirmwareCore::write(sendBuffer,address,writeValue,1 /*size*/);
	OtsUDPHardware::write(sendBuffer); // data request
}

DEFINE_OTS_INTERFACE(FEOtsUDPTemplateInterface)

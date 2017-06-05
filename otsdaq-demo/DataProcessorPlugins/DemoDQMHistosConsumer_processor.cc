#include "otsdaq-core/DataProcessorPlugins/DQMHistosConsumer.h"
#include "otsdaq-core/ConfigurationPluginDataFormats/DQMHistosConsumerConfiguration.h"
#include "otsdaq-core/MessageFacility/MessageFacility.h"
#include "otsdaq-core/Macros/CoutHeaderMacros.h"
#include "otsdaq-core/Macros/ProcessorPluginMacros.h"



#include <unistd.h>

using namespace ots;


//========================================================================================================================
DQMHistosConsumer::DQMHistosConsumer(std::string supervisorApplicationUID, std::string bufferUID, std::string processorUID, const ConfigurationTree& theXDAQContextConfigTree, const std::string& configurationPath)
: WorkLoop             (processorUID)
, DQMHistos            (supervisorApplicationUID, bufferUID, processorUID)
, DQMHistosConsumerBase(supervisorApplicationUID, bufferUID, processorUID, LowConsumerPriority)
, Configurable   (theXDAQContextConfigTree, configurationPath)
, filePath_            (theXDAQContextConfigTree.getNode(configurationPath).getNode("FilePath").getValue<std::string>())
, fileRadix_           (theXDAQContextConfigTree.getNode(configurationPath).getNode("RadixFileName").getValue<std::string>())
, saveFile_            (theXDAQContextConfigTree.getNode(configurationPath).getNode("SaveFile").getValue<bool>())

{
}

//========================================================================================================================
DQMHistosConsumer::~DQMHistosConsumer(void)
{
	closeFile();
}

//========================================================================================================================
void DQMHistosConsumer::startProcessingData(std::string runNumber)
{
	//IMPORTANT
	//The file must be always opened because even the LIVE DQM uses the pointer to it
	openFile(filePath_ + "/" + fileRadix_ + "_Run" + runNumber + ".root");


	currentDirectory_ = theFile_->mkdir("General", "General");
	currentDirectory_->cd();
	sequenceNumbers_ = new TH1I("SequenceNumber", "Sequence Number", 256, 0, 255);

	dataNumbers_ = new TH1I("Data", "Data", 101, 0, 0x400000*100);

	//for(int i=40;i<80;++i)
	//	sequenceNumbers_->Fill(i);

	//DQMHistos::book();
	DataConsumer::startProcessingData(runNumber);
}

//========================================================================================================================
void DQMHistosConsumer::stopProcessingData(void)
{
	DataConsumer::stopProcessingData();
	if(saveFile_)
	{
		save();
	}
	closeFile();
}

//========================================================================================================================
bool DQMHistosConsumer::workLoopThread(toolbox::task::WorkLoop* workLoop)
{
	//__MOUT__ << DataProcessor::processorUID_ << " running, because workloop: " <<
	//	WorkLoop::continueWorkLoop_ << std::endl;
	fastRead();
	return WorkLoop::continueWorkLoop_;
}

//========================================================================================================================
void DQMHistosConsumer::fastRead(void)
{
	//__MOUT__ << processorUID_ << " running!" << std::endl;
	//This is making a copy!!!
	if(DataConsumer::read(dataP_, headerP_) < 0)
	{
		usleep(100);
		return;
	}
	__MOUT__ << DataProcessor::processorUID_ << " UID: " << supervisorApplicationUID_ << std::endl;

	//HW emulator
	//	 Burst Type | Sequence | 8B data

	__MOUT__ << "Size fill: " << dataP_->length() << std::endl;

	unsigned long long dataQW = *((unsigned long long *)&((*dataP_)[2]));
	{ //print
		__SS__ << "dataP Read: 0x ";
		for(unsigned int i=0; i<(*dataP_).size(); ++i)
			ss << std::hex << (int)(((*dataP_)[i]>>4)&0xF) <<
			(int)(((*dataP_)[i])&0xF) << " " << std::dec;
		ss << std::endl;
		__MOUT__ << "\n" << ss.str();

		__MOUT__ << "sequence = " << (int)*((unsigned char *)&((*dataP_)[1])) << std::endl;

		__MOUT__ << "dataQW = 0x" << std::hex << (dataQW) << " " <<
				std::dec << dataQW << std::endl;
	}


	sequenceNumbers_->Fill(
			(unsigned int)(
			*((unsigned char *)&((*dataP_)[1]))
			));
	dataNumbers_->Fill(
			dataQW
			//*((unsigned long long *)&((*dataP_)[2]))
			);


	//DQMHistos::fill(*dataP_,*headerP_);
	DataConsumer::setReadSubBuffer<std::string, std::map<std::string, std::string>>();
}

//========================================================================================================================
void DQMHistosConsumer::slowRead(void)
{
	//__MOUT__ << DataProcessor::processorUID_ << " running!" << std::endl;
	//This is making a copy!!!
	if(DataConsumer::read(data_, header_) < 0)
	{
		usleep(1000);
		return;
	}
	__MOUT__ << DataProcessor::processorUID_ << " UID: " << supervisorApplicationUID_ << std::endl;
	//DQMHistos::fill(data_,header_);
}

DEFINE_OTS_PROCESSOR(DQMHistosConsumer)

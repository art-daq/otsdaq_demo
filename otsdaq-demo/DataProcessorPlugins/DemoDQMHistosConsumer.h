#ifndef _ots_DQMHistosConsumer_h_
#define _ots_DQMHistosConsumer_h_

#include "otsdaq-core/DataManager/DQMHistosConsumerBase.h"
#include "otsdaq-core/ConfigurationInterface/Configurable.h"
#include "otsdaq-demo/DataProcessorPlugins/DemoDQMHistos.h"



#include <TH1.h>
#include <TH2.h>
#include <TH1F.h>
#include <TH2F.h>
#include <TProfile.h>
#include <TCanvas.h>
#include <TFrame.h>
#include <TRandom.h>
#include <TThread.h>
#include <TROOT.h>
#include <TFile.h>
#include <TDirectory.h>


#include <string>

namespace ots
{

  class ConfigurationManager;

class DQMHistosConsumer : public DQMHistos, public DQMHistosConsumerBase, public Configurable
{
public:
  DQMHistosConsumer(std::string supervisorApplicationUID, std::string bufferUID, std::string processorUID, const ConfigurationTree& theXDAQContextConfigTree, const std::string& configurationPath);
	virtual ~DQMHistosConsumer(void);

	void startProcessingData(std::string runNumber) override;
	void stopProcessingData (void) override;

private:
	bool workLoopThread(toolbox::task::WorkLoop* workLoop);
	void fastRead(void);
	void slowRead(void);
	
	
	//For fast read
	std::string*                       dataP_;
	std::map<std::string,std::string>* headerP_;
	//For slow read
	std::string                        data_;
	std::map<std::string,std::string>  header_;

	std::string                        filePath_;
	std::string                        fileRadix_;
	bool                               saveFile_; //yes or no



	  TH1I*                 sequenceNumbers_;
	  TH1I*                 dataNumbers_;


};
}

#endif

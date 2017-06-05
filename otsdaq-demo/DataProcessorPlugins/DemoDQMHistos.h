#ifndef _ots_DQMHistos_h_
#define _ots_DQMHistos_h_

#include "otsdaq-core/RootUtilities/DQMHistosBase.h"
#include <queue>
#include <string>
#include <map>
//ROOT documentation
//http://root.cern.ch/root/html/index.html

class TFile;
class TCanvas;       
class TH1;
class TH1I;
class TH1F;          
class TH2F;          
class TProfile;      
class TDirectory;
class TObject;

namespace ots
{

class ConfigurationManager;

class DQMHistos
{
 public:
  DQMHistos(std::string supervisorApplicationUID, std::string bufferUID, std::string processorUID);
  virtual ~DQMHistos(void);
  void     book(
		        const ConfigurationTree & theXDAQContextConfigTree,
		        const std::string       & configurationPath
		       );
  void     fill(std::string& buffer, std::map<std::string, std::string> header);
  void     load(std::string fileName);

  //Getters
  //TCanvas*  getCanvas (void){return canvas_;}
  //TH1F*     getHisto1D(void){return histo1D_;}
  //TH2F*     getHisto2D(void){return histo2D_;}
  //TProfile* getProfile(void){return profile_;}


 protected:
  //DataDecoder          theDataDecoder_;
  std::queue<uint32_t> convertedBuffer_;

  //TCanvas*      canvas_; // main canvas
  //TH1F*         histo1D_;// 1-D histogram
  //TH2F*         histo2D_;// 2-D histogram
  //TProfile*     profile_;// profile histogram
  //       IPAddress          port                channel
  std::map<std::string, std::map<std::string, std::map<unsigned int, TH1*>>> planeOccupancies_;
  //std::vector<TH1I*> planeOccupancies_;
  TH1I*                 numberOfTriggers_;
  const std::string     bufferUID_;
  const std::string     processorUID_;
};
}

#endif

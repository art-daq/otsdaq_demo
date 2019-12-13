#ifndef _ots_SlowControlsInterfaceTemplate_h
#define _ots_SlowControlsInterfaceTemplate_h

#include <array>
#include <string>

#include "otsdaq/SlowControlsCore/SlowControlsVInterface.h"

namespace ots
{
// clang-format off
class SlowControlsInterfaceTemplate : public SlowControlsVInterface
{
  public:
	SlowControlsInterfaceTemplate(const std::string&       pluginType,
	                              const std::string&       interfaceUID,
	                              const ConfigurationTree& theXDAQContextConfigTree,
	                              const std::string&       controlsConfigurationPath);
	~SlowControlsInterfaceTemplate();

	void initialize();
	void destroy();

    std::vector<std::string /*Name*/> 			getChannelList();
	std::string                					getList(std::string format);
	void                       					subscribe(std::string Name);
	void                       					subscribeJSON(std::string List);
	void                       					unsubscribe(std::string Name);
	std::array<std::string, 4> 					getCurrentValue(std::string Name);
	std::array<std::string, 9>					getSettings(std::string Name);
	std::vector<std::vector<std::string>> 		getChannelHistory(std::string Name);

	virtual bool 								running(void) override; //This is a workloop/thread, by default do nothing and end thread during running (Note: return true would repeat call)

};
// clang-format on
}

#endif

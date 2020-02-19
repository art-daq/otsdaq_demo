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
	~SlowControlsInterfaceTemplate(void);

	void initialize();
	void destroy();

    std::vector<std::string /*Name*/> 			getChannelList		(void);
	std::string                					getList				(const std::string& format);
	void                       					subscribe			(const std::string& Name);
	void                       					subscribeJSON		(const std::string& List);
	void                       					unsubscribe			(const std::string& Name);
	std::array<std::string, 4> 					getCurrentValue		(const std::string& Name);
	std::array<std::string, 9>					getSettings			(const std::string& Name);
	std::vector<std::vector<std::string>> 		getChannelHistory	(const std::string& Name);

	virtual bool 								running				(void) override; //This is a workloop/thread, by default do nothing and end thread during running (Note: return true would repeat call)

};
// clang-format on
}

#endif

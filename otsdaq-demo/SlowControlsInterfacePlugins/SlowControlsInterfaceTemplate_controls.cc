#include "otsdaq-demo/SlowControlsInterfacePlugins/SlowControlsInterfaceTemplate.h"
#include "otsdaq/Macros/SlowControlsPluginMacros.h"

using namespace ots;

SlowControlsInterfaceTemplate::SlowControlsInterfaceTemplate(
    const std::string&       pluginType,
    const std::string&       interfaceUID,
    const ConfigurationTree& theXDAQContextConfigTree,
    const std::string&       controlsConfigurationPath)
    //  :Socket            (
    //  theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("HostIPAddress").getValue<std::string>()
    // ,theXDAQContextConfigTree.getNode(interfaceConfigurationPath).getNode("HostPort").getValue<unsigned
    // int>())
    // ,
    : SlowControlsVInterface(
          pluginType, interfaceUID, theXDAQContextConfigTree, controlsConfigurationPath)
{
}

SlowControlsInterfaceTemplate::~SlowControlsInterfaceTemplate() { destroy(); }

void SlowControlsInterfaceTemplate::initialize() {}

void SlowControlsInterfaceTemplate::destroy() {}

std::string SlowControlsInterfaceTemplate::getList(std::string format)
{
	//__COUT__ << theXDAQContextConfigTree.getNode(controlsConfigurationPath).getValue <<
	// std::endl;
	return (std::string) "list";
}
void SlowControlsInterfaceTemplate::subscribe(std::string Name) {}

void SlowControlsInterfaceTemplate::subscribeJSON(std::string List) {}

void SlowControlsInterfaceTemplate::unsubscribe(std::string Name) {}

std::array<std::string, 4> SlowControlsInterfaceTemplate::getCurrentValue(
    std::string Name)
{
	return {"a", "b", "c", "d"};
}

std::array<std::string, 9> SlowControlsInterfaceTemplate::getSettings(std::string Name)
{
	return {"a", "b", "c", "d", "e", "f", "g", "h", "i"};
}

std::vector<std::vector<std::string>> SlowControlsInterfaceTemplate::getPVHistory(
    std::string Name)
{
	return {std::vector<std::string>({"a", "b", "c", "d", "e"}),
	        std::vector<std::string>({"b", "b", "c", "d", "e"}),
	        std::vector<std::string>({"c", "b", "c", "d", "e"}),
	        std::vector<std::string>({"d", "b", "c", "d", "e"}),
	        std::vector<std::string>({"e", "b", "c", "d", "e"}),
	        std::vector<std::string>({"f", "b", "c", "d", "e"}),
	        std::vector<std::string>({"g", "b", "c", "d", "e"}),
	        std::vector<std::string>({"h", "b", "c", "d", "e"}),
	        std::vector<std::string>({"i", "b", "c", "d", "e"}),
	        std::vector<std::string>({"j", "b", "c", "d", "e"})};
}

DEFINE_OTS_SLOW_CONTROLS(SlowControlsInterfaceTemplate)

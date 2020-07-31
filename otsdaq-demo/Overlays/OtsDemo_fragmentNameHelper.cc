#include "otsdaq-demo/Overlays/FragmentType.hh"
#include "artdaq-core/Data/FragmentNameHelper.hh"

#include "TRACE/tracemf.h"
#define TRACE_NAME "OtsDemoFragmentNameHelper"

namespace ots
{
/**
 * \brief OtsDemoFragmentNameHelper extends ArtdaqFragmentNamingService.
 * This implementation uses artdaq-demo's SystemTypeMap and directly assigns names based
 * on it
 */
class OtsDemoFragmentNameHelper : public artdaq::ArtdaqFragmentNameHelper
{
  public:
	/**
	 * \brief DefaultArtdaqFragmentNamingService Destructor
	 */
	~OtsDemoFragmentNameHelper() override = default;

	/**
	 * \brief OtsDemoFragmentNameHelper Constructor
	 */
	OtsDemoFragmentNameHelper(
	    std::string unidentified_instance_name,
	    std::vector<std::pair<artdaq::Fragment::type_t, std::string>> extraTypes);

  private:
	OtsDemoFragmentNameHelper(OtsDemoFragmentNameHelper const&) = delete;
	OtsDemoFragmentNameHelper(OtsDemoFragmentNameHelper&&)      = delete;
	OtsDemoFragmentNameHelper& operator=(OtsDemoFragmentNameHelper const&) = delete;
	OtsDemoFragmentNameHelper& operator=(OtsDemoFragmentNameHelper&&) = delete;
};

OtsDemoFragmentNameHelper::OtsDemoFragmentNameHelper(
    std::string unidentified_instance_name,
    std::vector<std::pair<artdaq::Fragment::type_t, std::string>> extraTypes)
    : ArtdaqFragmentNameHelper(unidentified_instance_name, extraTypes)
{
	TLOG(TLVL_DEBUG) << "OtsDemoFragmentNameHelper CONSTRUCTOR START";
	SetBasicTypes(ots::makeFragmentTypeMap());
	TLOG(TLVL_DEBUG) << "OtsDemoFragmentNameHelper CONSTRUCTOR END";
}
}  // namespace ots

DEFINE_ARTDAQ_FRAGMENT_NAME_HELPER(ots::OtsDemoFragmentNameHelper)
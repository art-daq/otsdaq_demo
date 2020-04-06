#include "artdaq/ArtModules/ArtdaqFragmentNamingService.h"
#include "otsdaq-demo/Overlays/FragmentType.hh"

#include "TRACE/tracemf.h"
#define TRACE_NAME "OtsDemoArtdaqFragmentNamingService"

/**
 * \brief OtsDemoArtdaqFragmentNamingService extends ArtdaqFragmentNamingService.
 * This implementation uses artdaq-demo's SystemTypeMap and directly assigns names based on it
 */
class OtsDemoArtdaqFragmentNamingService : public ArtdaqFragmentNamingService
{
  public:
	/**
	 * \brief DefaultArtdaqFragmentNamingService Destructor
	 */
	virtual ~OtsDemoArtdaqFragmentNamingService() = default;

	/**
	 * \brief OtsDemoArtdaqFragmentNamingService Constructor
	 */
	OtsDemoArtdaqFragmentNamingService(fhicl::ParameterSet const&,
	                                   art::ActivityRegistry&);

  private:
};

OtsDemoArtdaqFragmentNamingService::OtsDemoArtdaqFragmentNamingService(
    fhicl::ParameterSet const& ps, art::ActivityRegistry& r)
    : ArtdaqFragmentNamingService(ps, r)
{
	TLOG(TLVL_DEBUG) << "OtsDemoArtdaqFragmentNamingService CONSTRUCTOR START";
	SetBasicTypes(ots::makeFragmentTypeMap());
	TLOG(TLVL_DEBUG) << "OtsDemoArtdaqFragmentNamingService CONSTRUCTOR END";
}

DECLARE_ART_SERVICE_INTERFACE_IMPL(OtsDemoArtdaqFragmentNamingService,
                                   ArtdaqFragmentNamingServiceInterface,
                                   LEGACY)
DEFINE_ART_SERVICE_INTERFACE_IMPL(OtsDemoArtdaqFragmentNamingService,
                                  ArtdaqFragmentNamingServiceInterface)
# ======================================================================
#  otsdaq-demo main build file
#
#  cd .../path/to/build/directory
#  source .../path/to/otsdaq-demo/ups/setup_for_development
#  buildtool
# ======================================================================


# use cmake 3.17 or later
cmake_minimum_required (VERSION 3.19 FATAL_ERROR)

find_package(cetmodules 3.16.00 REQUIRED)

project(otsdaq_demo VERSION 2.06.07)

include(CetCMakeEnv)
cet_cmake_env()

if (CMAKE_CXX_COMPILER_ID STREQUAL Clang AND
     CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 14.0.0)
  set(DT_FLAG -Wno-dtor-name)
else()
  set(DT_FLAG)
endif()

cet_set_compiler_flags(DIAGS VIGILANT
 WERROR
 NO_UNDEFINED
 EXTRA_FLAGS -pedantic -D_LIBCPP_ENABLE_CXX17_REMOVED_FEATURES=1 ${DT_FLAG}
 )

#cet_report_compiler_flags()

find_package(otsdaq 2.06.06 REQUIRED)
find_package(otsdaq_components 2.06.06 REQUIRED)
 
 # XDAQ Extra setup
 include_directories($ENV{XDAQ_INC}/linux $ENV{XDAQ_INC})
link_directories($ENV{XDAQ_LIB})
link_directories($ENV{ARTDAQ_DATABASE_LIB})
 set(XDAQ_BASIC_LIB_LIST 
   xcept
   xoap
   xdaq
   toolbox
   xerces-c
   cgicc
 )
 set(XDAQ_XERCES-C xerces-c)
 
#string(REGEX MATCHALL "[0-9][0-9]?[0-9]?" ART_VERSION_LIST "$ENV{ART_VERSION}")
#list(GET ART_VERSION_LIST 0 ART_MAJOR_VERSION)
#list(GET ART_VERSION_LIST 1 ART_MINOR_VERSION)
#list(GET ART_VERSION_LIST 2 ART_PATCH_VERSION)

#message("-DART_HEX_VERSION=0x${ART_MAJOR_VERSION}${ART_MINOR_VERSION}${ART_PATCH_VERSION}")
#set(ART_HEX_VERSION 0x${ART_MAJOR_VERSION}${ART_MINOR_VERSION}${ART_PATCH_VERSION})
#add_definitions(-DART_HEX_VERSION=0x${ART_MAJOR_VERSION}${ART_MINOR_VERSION}${ART_PATCH_VERSION})

#string(REGEX MATCHALL "[0-9][0-9]?[0-9]?" MESSAGEFACILITY_VERSION_LIST "$ENV{MESSAGEFACILITY_VERSION}")
#list(GET MESSAGEFACILITY_VERSION_LIST 0 MESSAGEFACILITY_MAJOR_VERSION)
#list(GET MESSAGEFACILITY_VERSION_LIST 1 MESSAGEFACILITY_MINOR_VERSION)
#list(GET MESSAGEFACILITY_VERSION_LIST 2 MESSAGEFACILITY_PATCH_VERSION)

#message("-DMESSAGEFACILITY_HEX_VERSION=0x${MESSAGEFACILITY_MAJOR_VERSION}${MESSAGEFACILITY_MINOR_VERSION}${MESSAGEFACILITY_PATCH_VERSION}")
#add_definitions(-DMESSAGEFACILITY_HEX_VERSION=0x${MESSAGEFACILITY_MAJOR_VERSION}${MESSAGEFACILITY_MINOR_VERSION}${MESSAGEFACILITY_PATCH_VERSION})

#string(REGEX MATCHALL "[0-9][0-9]?[0-9]?" CANVAS_VERSION_LIST "$ENV{CANVAS_VERSION}")
#list(GET CANVAS_VERSION_LIST 0 CANVAS_MAJOR_VERSION)
#list(GET CANVAS_VERSION_LIST 1 CANVAS_MINOR_VERSION)
#list(GET CANVAS_VERSION_LIST 2 CANVAS_PATCH_VERSION)

#message("-DCANVAS_HEX_VERSION=0x${CANVAS_MAJOR_VERSION}${CANVAS_MINOR_VERSION}${CANVAS_PATCH_VERSION}")
#add_definitions(-DCANVAS_HEX_VERSION=0x${CANVAS_MAJOR_VERSION}${CANVAS_MINOR_VERSION}${CANVAS_PATCH_VERSION})

# Code
add_subdirectory(otsdaq-demo)

# Useful scripts
add_subdirectory(tools)

# Test Programs
add_subdirectory(test)

# Documentation directory
if( $ENV{OTS_DOXY} MATCHES "DOIT" )
	add_subdirectory(doc)
endif()

cet_cmake_config()

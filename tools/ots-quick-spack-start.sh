#! /bin/bash
# quick-mrb-start.sh - Eric Flumerfelt, May 20, 2016
# Downloads, installs, and runs the artdaq_demo as an MRB-controlled repository

git_status=`git status 2>/dev/null`
git_sts=$?
if [ $git_sts -eq 0 ];then
    echo "This script is designed to be run in a fresh install directory!"
    exit 1
fi

starttime=`date`
Base=$PWD
test -d log || mkdir log
test -d Data && rmdir Data
test -d databases && rmdir databases

env_opts_var=`basename $0 | sed 's/\.sh$//' | tr 'a-z-' 'A-Z_'`_OPTS
USAGE="\
   usage: `basename $0` [options] [demo_root]
examples: `basename $0` .
          `basename $0` --run-ots
          `basename $0` --debug
          `basename $0` --tag v2_08_04
If the \"demo_root\" optional parameter is not supplied, the user will be
prompted for this location.
--run-ots     runs otsdaq
--debug       perform a debug build
--develop     Install the develop version of the software (may be unstable!)
--dev-only    Do not install otsdaq-suite in a local environment (use with --upstream!)
--tag         Install a specific tag of otsdaq
--spackdir    Install Spack in this directory (or use existing installation)
-a            Artdaq version number (e.g. 31300 for v3_13_00)
-s            Use specific qualifiers when building ots
-v            Be more verbose
-x            set -x this script
-w            Check out repositories read/write
--no-extra-products  Skip the automatic use of central product areas, such as CVMFS
--upstream    Use <dir> as a Spack upstream (repeatable)
--padding     Set directory padding to 255, for relocatability
--no-view     Do not create Spack environment views
--arch        Set architechture for build (ex. linux-almalinux9-x86_64_v3)
--no-kmod     Do not build TRACE kernel module (for Docker builds)
"

# Process script arguments and options
eval env_opts=\${$env_opts_var-} # can be args too

spackdir="${SPACK_ROOT:-$Base/spack}"
upstreams=()
installStatus=0
eval "set -- $env_opts \"\$@\""
op1chr='rest=`expr "$op" : "[^-]\(.*\)"`   && set -- "-$rest" "$@"'
op1arg='rest=`expr "$op" : "[^-]\(.*\)"`   && set --  "$rest" "$@"'
reqarg="$op1arg;"'test -z "${1+1}" &&echo opt -$op requires arg. &&echo "$USAGE" &&exit'
args= do_help= opt_v=0; opt_w=0; opt_develop=0; opt_skip_extra_products=0; opt_no_pull=0; opt_padding=0; opt_no_kmod=0; opt_no_view=0; opt_dev_only=0
while [ -n "${1-}" ];do
    if expr "x${1-}" : 'x-' >/dev/null;then
        op=`expr "x$1" : 'x-\(.*\)'`; shift   # done with $1
        leq=`expr "x$op" : 'x-[^=]*\(=\)'` lev=`expr "x$op" : 'x-[^=]*=\(.*\)'`
        test -n "$leq"&&eval "set -- \"\$lev\" \"\$@\""&&op=`expr "x$op" : 'x\([^=]*\)'`
        case "$op" in
            \?*|h*)     eval $op1chr; do_help=1;;
            v*)         eval $op1chr; opt_v=`expr $opt_v + 1`;;
            x*)         eval $op1chr; set -x;;
            a*)         eval $op1arg; aqualifier=$1; shift;;
            s*)         eval $op1arg; squalifier=$1; shift;;
            w*)         eval $op1chr; opt_w=`expr $opt_w + 1`;;
            -debug)     opt_debug=--debug;;
            -run-ots)   opt_run_ots=--run-ots;;
            -develop)   opt_develop=1;;
            -dev-only)  opt_dev_only=1;;
            -tag)       eval $reqarg; tag=$1; shift;;
            -spackdir)  eval $op1arg; spackdir=$1; shift;;
            -no-extra-products)  opt_skip_extra_products=1;;
            -no-pull)   opt_no_pull=1;;
            -upstream)  eval $op1arg; upstreams+=($1); shift;;
            -padding)   opt_padding=1;;
            -arch)      eval $op1arg; arch=$1; shift;;
            -no-kmod)   opt_no_kmod=1;;
            -no-view)   opt_no_view=1;;
            *)          echo "Unknown option -$op"; do_help=1;;
        esac
    else
        aa=`echo "$1" | sed -e"s/'/'\"'\"'/g"` args="$args '$aa'"; shift
    fi
done
eval "set -- $args \"\$@\""; unset args aa

test -n "${do_help-}" -o $# -ge 2 && echo "$USAGE" && exit

if [ "x$SPACK_ROOT" == "x$spackdir" ]; then
  echo "Using pre-existing Spack installation $SPACK_ROOT.\nIf this is not correct, hit Ctrl-C and run 'unset SPACK_ROOT'."
  sleep 5
  spack env deactivate
fi

# JCF, 1/16/15
# Save all output from this script (stdout + stderr) in a file with a
# name that looks like "quick-start.sh_Fri_Jan_16_13:58:27.script" as
# well as all stderr in a file with a name that looks like
# "quick-start.sh_Fri_Jan_16_13:58:27_stderr.script"
alloutput_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4".script"}' )
stderr_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4"_stderr.script"}' )
exec  > >(tee "$Base/qms-log/$alloutput_file")
exec 2> >(tee "$Base/qms-log/$stderr_file")

# Get all the information we'll need to decide which exact flavor of the software to install
notag=0
if [ -z "${tag:-}" ]; then
  tag=develop;
  notag=1;
fi

rm CMakeLists.txt*
wget https://raw.githubusercontent.com/art-daq/otsdaq/$tag/CMakeLists.txt
demo_version=v`grep "project" $Base/CMakeLists.txt|grep -oE "VERSION [^)]*"|awk '{print $2}'|sed 's/\./_/g'`
echo "ots Version is $demo_version"
if [[ $notag -eq 1 ]] && [[ $opt_develop -eq 0 ]]; then
  tag=$demo_version

  # 06-Mar-2017, KAB: re-fetch the product_deps file based on the tag
  mv CMakeLists.txt CMakeLists.txt.orig
  wget https://raw.githubusercontent.com/art-daq/otsdaq/$tag/CMakeLists.txt
  demo_version=v`grep "project" $Base/CMakeLists.txt|grep -oE "VERSION [^)]*"|awk '{print $2}'|sed 's/\./_/g'`
  tag=$demo_version
fi

svariant=""
advariant=""

if [ -n "${squalifier-}" ]; then
    svariant="s=${squalifier}"
fi
if [ -n "${aqualifier-}" ]; then
    advariant="artdaq=${aqualifier}"
fi

arch_opt=""
if [ "x$arch" != "x" ]; then
   arch_opt="arch=$arch"
fi

view_opt=""
if [ $opt_no_view -eq 1 ];then
    view_opt="--without-view"
fi

if ! [ -d $spackdir ];then
    $(
    cd ${spackdir%/spack}
    git clone https://github.com/FNALssi/spack.git -b fnal-develop
    cd $spackdir && git checkout e18ecaaa780b863b2104e2971d3320c97ebf3b65
        )
else
    #cd $spackdir && git pull && cd $Base
    cd $spackdir && git fetch -a && git checkout e18ecaaa780b863b2104e2971d3320c97ebf3b65 && cd $Base
fi

cat >setup-env.sh <<-EOF
export SPACK_DISABLE_LOCAL_CONFIG=true
source $spackdir/share/spack/setup-env.sh
EOF
source setup-env.sh

if ! [ -d fermi-spack-tools ]; then
    #git clone https://github.com/FNALssi/fermi-spack-tools.git # Upstream
    #cd fermi-spack-tools && git checkout 965e0e73896328f8137c2bd53bad77a42b39e0bf; cd $Base
    git clone https://github.com/eflumerf/fermi-spack-tools.git # Fork
    cd fermi-spack-tools && git checkout StableWithCairoFix; cd $Base
else
    #cd fermi-spack-tools && git fetch -a && git checkout 965e0e73896328f8137c2bd53bad77a42b39e0bf ; cd $Base
    cd fermi-spack-tools && git fetch -a && git checkout StableWithCairoFix ; cd $Base
fi
if ! [ -d spack-mpd ]; then
    # git clone https://github.com/FNALssi/spack-mpd.git # Upstream
    git clone https://github.com/eflumerf/spack-mpd.git # Fork
else
    cd spack-mpd && git pull && cd ..
fi

sed -i '/perl/d' fermi-spack-tools/templates/packagelist
if [ -f $spackdir/etc/spack/`uname -s | tr [A-Z] [a-z]`/almalinux9/packages.yaml ];then
    echo "Skipping ./fermi-spack-tools/bin/make_packages_yaml $spackdir almalinux9"
    echo "... $spackdir/etc/spack/`uname -s | tr [A-Z] [a-z]`/almalinux9/packages.yaml already exists"
else
    echo "executing ./fermi-spack-tools/bin/make_packages_yaml $spackdir almalinux9"
    echo "... to produce $spackdir/etc/spack/`uname -s | tr [A-Z] [a-z]`/almalinux9/packages.yaml"
    ./fermi-spack-tools/bin/make_packages_yaml $spackdir almalinux9
fi

repo_found=`spack repo list|grep -c fnal_art`
if [ $repo_found -eq 0 ]; then
    echo "Adding repos: fnal_art scd_recipes artdaq-spack"
    mkdir spack-repos;cd spack-repos
    git clone https://github.com/FNALssi/fnal_art.git
    cd fnal_art && git checkout ddeec355456e3bca5e4a743ce5d4906fa74a51b6 ; cd ..
    spack repo add ./fnal_art
    git clone https://github.com/marcmengel/scd_recipes.git
    cd scd_recipes && git checkout e9c8cc8af792008c3c85724cc8ae3ee0662233d6 ; cd ..
    spack repo add ./scd_recipes
    git clone https://github.com/art-daq/artdaq-spack.git
    cd artdaq-spack && git checkout ots-${demo_version}; cd ..
    spack repo add ./artdaq-spack
    cd $Base
else
    cd fnal_art && git fetch -a && git checkout ddeec355456e3bca5e4a743ce5d4906fa74a51b6 ; cd ..
    cd scd_recipes && git fetch -a && git checkout e9c8cc8af792008c3c85724cc8ae3ee0662233d6 ; cd ..
    cd artdaq-spack && git fetch -a && git checkout ots-${demo_version}; cd ..
    cd $Base
fi

spack config --scope=site add "config:extensions:- $Base/spack-mpd"

if [ $opt_padding -eq 1 ];then
  spack config --scope=site add config:install_tree:padded_length:255
fi

concrete_include_cmd=

for upstream in ${upstreams[@]}; do
    for upstreamdir in `find $upstream -type f -wholename '*/.spack-db/index.json' 2>/dev/null`; do
        echo "Getting real directory for upstream database $upstreamdir"
        upstreamdir=`dirname $upstreamdir`
        upstreamdir=`dirname $upstreamdir`
        upstreamdir=`realpath $upstreamdir`
        upstreamname=`echo $upstreamdir|sed 's|/__spack[^/]*||g;s|/spack/opt/spack||g'`

        if ! [ -d $upstreamdir/.spack-db ]; then
            echo "No Spack instance found at $upstream!"
            continue
        fi

        if ! [ -f $spackdir/etc/spack/upstreams.yaml ]; then
            echo "upstreams:" > $spackdir/etc/spack/upstreams.yaml
        fi

        if [ `grep -c $upstreamdir $spackdir/etc/spack/upstreams.yaml` -eq 0 ]; then
            # Only add upstream if not already present
            echo "  upstream${upstreamname//\//-}:" >>$spackdir/etc/spack/upstreams.yaml
            echo "    install_tree: $upstreamdir" >>$spackdir/etc/spack/upstreams.yaml
        fi
    done

    for envdir in `find $upstream -type d -wholename '*/var/spack/environments' 2>/dev/null`; do
        echo "Looking for otsdaq environments in $envdir"

        environment="ots-${demo_version}"
        if ! [ -d $environment ]; then continue; fi
        environment_dir=`realpath $environment`
        echo "Adding environment $environment_dir to include-concrete list"
        concrete_include_cmd="$concrete_include_cmd --include-concrete $environment_dir"
    done
done

spack reindex

cd $Base

BUILD_J=$((`cat /proc/cpuinfo|grep processor|tail -1|awk '{print $3}'` + 1))
spack load --first gcc@13.1.0 >/dev/null 2>&1
if [ $? -ne 0 ]; then
  spack install --deprecated -j $BUILD_J gcc@13.1.0 ${arch_opt} +binutils
  installStatus=$?
  spack load gcc@13.1.0
fi
spack compiler find

if [ ${opt_dev_only:-0} -eq 0 ];then
    spack env create ${concrete_include_cmd} $view_opt ots-${demo_version}
    spack env activate ots-${demo_version}
    ln -s ${spackdir}/var/spack/environments/ots-${demo_version}

    # OTS always wants to re-make the srcs link
    if ! [ -d srcs ];then
        rm srcs >/dev/null 2>&1
        ln -s $spackdir/var/spack/environments/ots-${demo_version} srcs
    fi

    if [ $opt_no_kmod -eq 1 ];then
        spack add trace~kmod
    else
        spack add trace+kmod
    fi

    spack add otsdaq-suite@${demo_version} ${svariant} ${advariant} ${arch_opt} %gcc@13.1.0 +demo
    env_to_activate="ots-${demo_version}"
fi

function checkout_package()
{
    pkg=$1
    if ! [ -d $pkg ]; then
        if [ $opt_w -eq 0 ];then
            git clone https://github.com/art-daq/$pkg.git
        else
            git clone git@github.com:art-daq/$pkg.git
        fi
    else
        cd $pkg
        git pull
        cd ..
    fi
}

if [[ ${opt_develop:-0} -eq 1 ]];then
    env_to_activate="ots-develop"
    cd $Base
    rm srcs
    mkdir srcs
    cd srcs
    for pkg in otsdaq otsdaq-demo otsdaq-utilities otsdaq-components otsdaq-epics otsdaq-prepmodernization;do
        checkout_package $pkg
    done
    cd $Base
fi

    cat >setup_ots.sh <<-EOF
echo # This script is intended to be sourced.

SCRIPT_DIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
otsdir=\$SCRIPT_DIR

sh -c "[ \`ps \$\$ | grep bash | wc -l\` -gt 0 ] || { echo 'Please switch to the bash shell before running ots.'; exit; }" || exit
export SPACK_DISABLE_LOCAL_CONFIG=true
source $spackdir/share/spack/setup-env.sh

spack load --first gcc@13.1.0
spack compiler find

spack env activate ${env_to_activate}
if [ -d $Base/local/install ]; then
  export PATH=$Base/local/install/bin:\$PATH
  export LD_LIBRARY_PATH=$Base/local/install/lib:\$LD_LIBRARY_PATH
  export CET_PLUGIN_PATH=$Base/local/install/lib:\$CET_PLUGIN_PATH
  export FHICL_FILE_PATH=$Base/local/install/fcl:$FHICL_FILE_PATH

  export OTSDAQ_DIR=\${OTSDAQ_DIR:-\$SCRIPT_DIR/local/install} #only set if not set by spack, e.g. needed by UpdateOTS.sh
  export OTSDAQ_LIB=\${OTSDAQ_LIB:-\$SCRIPT_DIR/local/install/lib} #only set if not set by spack, e.g. needed by otsConfiguration_Wizard_CMake.xml, otsConfiguration_MacroMaker_CMake.xml
  export OTSDAQ_UTILITIES_LIB=\${OTSDAQ_UTILITIES_LIB:-\$SCRIPT_DIR/local/install/lib} #only set if not set by spack, needed by otsConfiguration_Wizard_CMake.xml, otsConfiguration_MacroMaker_CMake.xml

  # in ots-develop mode, set WebPath because OTSDAQ_UTILITIES_DIR is not setup
  if [ -d \$SCRIPT_DIR/srcs/otsdaq-utilities/WebGUI ]; then
      export OTSDAQ_WEB_PATH=\$SCRIPT_DIR/srcs/otsdaq-utilities/WebGUI
  else
      export OTSDAQ_WEB_PATH=\$OTSDAQ_UTILITIES_LIB/../WebGUI
  fi
  export OTS_FILE_PARSE_PATTERN="/srcs/" #will be used to parse filename (i.e. for TRACE)
fi

k5user=\`klist|grep "Default principal"|cut -d: -f2|sed 's/@.*//;s/ //'\`
export TRACE_FILE=/tmp/trace_buffer_\$USER.\$k5user

export OTS_MAIN_PORT=2015

export USER_DATA="$Base/Data"
export ARTDAQ_DATABASE_URI="filesystemdb://$Base/databases/filesystemdb/test_db"
export OTSDAQ_DATA="$Base/Data/OutputData"
export OTS_SOURCE=$Base/srcs

echo -e "setup_ots.sh:\${LINENO} |  \t  Now your user data path is USER_DATA \t\t = \${USER_DATA}"
echo -e "setup_ots.sh:\${LINENO} |  \t  Now your database path is ARTDAQ_DATABASE_URI \t = \${ARTDAQ_DATABASE_URI}"
echo -e "setup_ots.sh:\${LINENO} |  \t  Now your output data path is OTSDAQ_DATA \t = \${OTSDAQ_DATA}"
echo

#make the number of build threads dependent on the number of cores on the machine:
export CETPKG_J=\$((`cat /proc/cpuinfo|grep processor|tail -1|awk '{print $3}'` + 1))

alias  kx='ots -k'
# When using upstream spack-mpd
#alias  mb='date; start_time=\$(date +%s); spack find | grep gcc; spack mpd build -j\$CETPKG_J 2>&1 | sed s/__spack_path_placeholder__//g | sed s/\\\[padded-to-255-chars\\\]//g | sed s/\\\/tdaq-v......../\\\/tdaq-v_\ \ \ /g; end_time=\$(date +%s); pushd $Base/build; ninja install; popd; date; delta_time=\$((end_time - start_time)); fractional_minutes=\$(echo "scale=1; \$delta_time / 60" | bc); echo "Full time: \$delta_time seconds or \$fractional_minutes minutes"'
#alias  ml='date; start_time=\$(date +%s); spack find | grep gcc; spack mpd build -j\$CETPKG_J 2>&1 | sed s/__spack_path_placeholder__//g | sed s/\\\[padded-to-255-chars\\\]//g | sed s/\\\/tdaq-v......../\\\/tdaq-v_\ \ \ /g | tee m.txt; end_time=\$(date +%s); pushd $Base/build; ninja install; popd; date; delta_time=$((end_time - start_time)); fractional_minutes=\$(echo "scale=1; \$delta_time / 60" | bc); echo "Full time: \$delta_time seconds or \$fractional_minutes minutes"; less m.txt'
#alias  mz='date; start_time=\$(date +%s); spack concretize --force --deprecated; spack mpd build --clean -j\$CETPKG_J 2>&1 | sed s/__spack_path_placeholder__//g; end_time=\$(date +%s); pushd $Base/build; ninja install; popd; date; delta_time=\$((end_time - start_time)); fractional_minutes=\$(echo "scale=1; \$delta_time / 60" | bc); echo "Full time: \$delta_time seconds or \$fractional_minutes minutes"'
# When using the fork of spack-mpd
alias  mb='date; start_time=\$(date +%s); spack find | grep gcc; spack mpd build -G Ninja -j\$CETPKG_J 2>&1 | sed s/__spack_path_placeholder__//g | sed s/\\\[padded-to-255-chars\\\]//g | sed s/\\\/tdaq-v......../\\\/tdaq-v_\ \ \ /g; end_time=\$(date +%s); pushd $Base/build; ninja install; popd; date; delta_time=\$((end_time - start_time)); fractional_minutes=\$(echo "scale=1; \$delta_time / 60" | bc); echo "Full time: \$delta_time seconds or \$fractional_minutes minutes"'
alias  ml='date; start_time=\$(date +%s); spack find | grep gcc; spack mpd build -G Ninja -j\$CETPKG_J 2>&1 | sed s/__spack_path_placeholder__//g | sed s/\\\[padded-to-255-chars\\\]//g | sed s/\\\/tdaq-v......../\\\/tdaq-v_\ \ \ /g | tee m.txt; end_time=\$(date +%s); pushd $Base/build; ninja install; popd; date; delta_time=$((end_time - start_time)); fractional_minutes=\$(echo "scale=1; \$delta_time / 60" | bc); echo "Full time: \$delta_time seconds or \$fractional_minutes minutes"; less m.txt'
alias  mz='date; start_time=\$(date +%s); spack concretize --force --deprecated; spack mpd build -G Ninja --clean -j\$CETPKG_J 2>&1 | sed s/__spack_path_placeholder__//g; end_time=\$(date +%s); pushd $Base/build; ninja install; popd; date; delta_time=\$((end_time - start_time)); fractional_minutes=\$(echo "scale=1; \$delta_time / 60" | bc); echo "Full time: \$delta_time seconds or \$fractional_minutes minutes"'


echo
echo -e "setup_ots.sh:\${LINENO} |  \t  Now use 'ots --wiz' to configure otsdaq"
echo -e "setup_ots.sh:\${LINENO} |  \t   	Then use 'ots' to start otsdaq"
echo -e "setup_ots.sh:\${LINENO} |  \t   	Or use 'ots --help' for more options"
echo
echo -e "setup_ots.sh:\${LINENO} |  \t      use 'kx' to kill otsdaq processes"
echo

echo -e "setup_ots.sh:\${LINENO} |  \t  "
echo -e "setup_ots.sh:\${LINENO} |  \t      setup_ots.sh creates some compiling aliases for you:"
echo -e "setup_ots.sh:\${LINENO} |  \t     ---------------"
echo -e "setup_ots.sh:\${LINENO} |  \t            mb                             ### for incremental build"
echo -e "setup_ots.sh:\${LINENO} |  \t            mz                             ### for clean build"
echo -e "setup_ots.sh:\${LINENO} |  \t     ---------------"
echo -e "setup_ots.sh:\${LINENO} |  \t  "
echo -e "setup_ots.sh:\${LINENO} |  \t  "

EOF
#


########################################
########################################
## Setup USER_DATA and databases
########################################
########################################
cd $Base

# Fetch data and databases from develop
git clone https://github.com/art-daq/otsdaq_demo -b develop
if ! [ -d databases ]; then
    cp -a otsdaq_demo/NoGitDatabases databases
fi
if ! [ -d Data ];then
    cp -a otsdaq_demo/NoGitData Data
fi
rm -rf otsdaq_demo

export USER_DATA="$Base/Data"
export ARTDAQ_DATABASE_URI="filesystemdb://$Base/databases/filesystemdb/test_db"


#download get_tutorial_data script
wget https://raw.githubusercontent.com/art-daq/otsdaq_demo/develop/tools/get_tutorial_data.sh -O get_tutorial_data.sh --no-check-certificate

#change permissions so the script is executable
chmod 755 get_tutorial_data.sh

#execute script
./get_tutorial_data.sh


#copy tutorial launching scripts
echo
echo -e "UpdateOTS.sh [${LINENO}]  \t updating tutorial launch scripts..."
rm get_tutorial_data.sh &>/dev/null 2>&1 #hide output
rm reset_ots_tutorial.sh &>/dev/null 2>&1 #hide output
wget https://raw.githubusercontent.com/art-daq/otsdaq_demo/develop/tools/reset_ots_tutorial.sh -O reset_ots_tutorial.sh --no-check-certificate
chmod 755 reset_ots_tutorial.sh


########################################
########################################
## END Setup USER_DATA and databases
########################################
########################################


if [ ${opt_dev_only:-0} -eq 0 ];then
    spack concretize --force --deprecated && spack install --deprecated -j $BUILD_J
    installStatus=$?
fi
if [[ ${opt_develop:-0} -eq 1 ]];then
    spack env deactivate
    # spack mpd init # Upstream
    spack mpd init -r site -u $Base/spack-repos/mpd # Fork
    if [ ${opt_dev_only:-0} -eq 0 ];then
        # spack mpd new-project --force -y --name ots-develop -E ots-${demo_version} cxxstd=20 %gcc@13.1.0 generator=ninja # Upstream
        spack mpd new-project --force -y --name ots-develop -E ots-${demo_version} cxxstd=20 %gcc@13.1.0 # Fork
    else
        # spack mpd new-project --force -y --name ots-develop cxxstd=20 %gcc@13.1.0 generator=ninja # Upstream
        spack mpd new-project --force -y --name ots-develop cxxstd=20 %gcc@13.1.0 # Fork
    fi
    spack env activate ots-develop
    spack add lcov # For coverage collection
    spack add canvas-root-io cxxstd=20 # Needed for now
    spack concretize --force --deprecated
    spack install --deprecated
    # spack mpd build # Upstream
    spack mpd build -G Ninja # Fork
    cd $Base/build
    ninja install
    installStatus=$?
    cd $Base
fi

if [ $installStatus -eq 0 ]; then
    echo "otsdaq-demo has been installed correctly. Use 'source setup_ots.sh' to setup your otsdaq software, then follow the instructions or visit the project redmine page for more info: https://github.com/art-daq/otsdaq/wiki"
    echo
    echo "In the future, when you open a new terminal, just use 'source setup_ots.sh' to setup your ots installation."
    echo
else
    echo "BUILD ERROR!!! SOMETHING IS VERY WRONG!!!"
    echo
    echo
fi

endtime=`date`

echo "Build start time: $starttime"
echo "Build end time:   $endtime"

exit $installStatus

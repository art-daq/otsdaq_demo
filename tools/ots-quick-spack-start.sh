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
args= do_help= opt_v=0; opt_w=0; opt_develop=0; opt_skip_extra_products=0; opt_no_pull=0; opt_padding=0; opt_no_kmod=0
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
            -run-ots)  opt_run_ots=--run-ots;;
            -develop) opt_develop=1;;
            -tag)       eval $reqarg; tag=$1; shift;;
            -spackdir)  eval $op1arg; spackdir=$1; shift;;
            -no-extra-products)  opt_skip_extra_products=1;;
            -no-pull)   opt_no_pull=1;;
            -upstream)  eval $op1arg; upstreams+=($1); shift;;
            -padding)   opt_padding=1;;
            -arch)      eval $op1arg; arch=$1; shift;;
            -no-kmod)   opt_no_kmod=1;;
            *)          echo "Unknown option -$op"; do_help=1;;
        esac
    else
        aa=`echo "$1" | sed -e"s/'/'\"'\"'/g"` args="$args '$aa'"; shift
    fi
done
eval "set -- $args \"\$@\""; unset args aa

test -n "${do_help-}" -o $# -ge 2 && echo "$USAGE" && exit

if [[ -n "${tag:-}" ]] && [[ $opt_develop -eq 1 ]]; then 
    echo "The \"--tag\" and \"--develop\" options are incompatible - please specify only one."
    exit
fi

if [ "x$SPACK_ROOT" == "x$spackdir" ]; then
  echo "Using pre-existing Spack installation $SPACK_ROOT.\nIf this is not correct, hit Ctrl-C and run 'unset SPACK_ROOT'."
  sleep 5
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

defaultS="132"
defaultAD="31301"

if [ -n "${squalifier-}" ]; then
    squalifier="${squalifier}"
else
    squalifier="${defaultS}"
fi
if [ -n "${aqualifier-}" ]; then
    aqualifier="${aqualifier}"
else
    aqualifier="${defaultAD}"
fi
compiler_info="" # Maybe do e- and c- qualifiers?

arch_opt=""
if [ "x$arch" != "x" ]; then
   arch_opt="arch=$arch"
fi

if ! [ -d $spackdir ];then
    $(
    cd ${spackdir%/spack}
    git clone https://github.com/FNALssi/spack.git -b fnal-develop
        )
else
    cd $spackdir && git pull && cd $Base
fi

export SPACK_DISABLE_LOCAL_CONFIG=true
source $spackdir/share/spack/setup-env.sh

if ! [ -d fermi-spack-tools ]; then
    git clone https://github.com/FNALssi/fermi-spack-tools.git
else
    cd fermi-spack-tools && git pull && cd ..
fi
if ! [ -d spack-mpd ]; then
    git clone https://github.com/eflumerf/spack-mpd.git
else
    cd spack-mpd && git pull && cd ..
fi

sed -i '/perl/d' fermi-spack-tools/templates/packagelist # Remove Perl for now
./fermi-spack-tools/bin/make_packages_yaml $spackdir almalinux9

repo_found=`spack repo list|grep -c fnal_art`
if [ $repo_found -eq 0 ]; then
    mkdir spack-repos && cd spack-repos
    git clone https://github.com/FNALssi/fnal_art.git
    spack repo add ./fnal_art
    git clone https://github.com/marcmengel/scd_recipes.git
    spack repo add ./scd_recipes
    git clone https://github.com/art-daq/artdaq-spack.git
    spack repo add ./artdaq-spack
    cd $Base
else
    for dir in `spack repo list|awk '{print $2}'`;do
        cd $dir
        git pull
    done
    cd $Base
fi


spack config --scope=site update  --yes-to-all config
#spack config --scope=site add config:flags:keep_werror:all # Not needed when using spack-mpd
spack config --scope=site add "config:extensions:- $Base/spack-mpd"
if [ $opt_padding -eq 1 ];then
  spack config --scope=site add config:install_tree:padded_length:255
fi

#spack mirror add --scope site scisoft-binaries  https://scisoft.fnal.gov/scisoft/spack-mirror/spack-binary-cache-plain
#spack buildcache update-index -k scisoft-binaries
#spack mirror add --scope site scisoft-compilers https://scisoft.fnal.gov/scisoft/spack-mirror/spack-compiler-cache-plain
#spack buildcache update-index -k scisoft-compilers
#spack -k buildcache keys --install --trust --force
#spack reindex

for upstream in ${upstreams[@]}; do
    upstreamdir=`find $upstream -type d -name .spack-db 2>/dev/null`
    upstreamdir=`dirname $upstreamdir`
    
    if ! [ -d $upstreamdir/.spack-db ]; then
       echo "No Spack instance found at $upstream!"
       continue
    fi

    if ! [ -f $spackdir/etc/spack/upstreams.yaml ]; then
        echo "upstreams:" > $spackdir/etc/spack/upstreams.yaml
    fi
    
    if [ `grep -c $upstreamdir $spackdir/etc/spack/upstreams.yaml` -eq 0 ]; then
        # Only add upstream if not already present
        echo "  upstream${upstream//\//-}:" >>$spackdir/etc/spack/upstreams.yaml
        echo "    install_tree: $upstreamdir" >>$spackdir/etc/spack/upstreams.yaml
    fi

done

cd $Base

BUILD_J=$((`cat /proc/cpuinfo|grep processor|tail -1|awk '{print $3}'` + 1))
spack load gcc@13.1.0 >/dev/null 2>&1
if [ $? -ne 0 ]; then
  spack install -j $BUILD_J $arch_opt gcc@13.1.0
  installStatus=$?
  spack load gcc@13.1.0
fi
spack compiler find

spack env create ots-${demo_version}
spack env activate ots-${demo_version}
ln -s ${spackdir}/var/spack/environments/ots-${demo_version}
# OTS always wants to re-make the srcs link
rm srcs >/dev/null 2>&1
ln -s $spackdir/var/spack/environments/ots-${demo_version} srcs

if [ $opt_no_kmod -eq 1 ];then
    spack add trace~kmod
fi

spack add otsdaq-suite@${demo_version}${compiler_info} s=${squalifier} artdaq=${aqualifier} $arch_opt %gcc@13.1.0 +demo
env_to_activate="ots-${demo_version}"


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

sh -c "[ \`ps \$\$ | grep bash | wc -l\` -gt 0 ] || { echo 'Please switch to the bash shell before running ots.'; exit; }" || exit
export SPACK_DISABLE_LOCAL_CONFIG=true
source $spackdir/share/spack/setup-env.sh

spack load gcc@13.1.0
spack compiler find

spack env activate ${env_to_activate}

k5user=\`klist|grep "Default principal"|cut -d: -f2|sed 's/@.*//;s/ //'\`
export TRACE_FILE=/tmp/trace_buffer_\$USER.\$k5user

export OTS_MAIN_PORT=2015

export USER_DATA="$Base/Data"
export ARTDAQ_DATABASE_URI="filesystemdb://$Base/databases/filesystemdb/test_db"
export OTSDAQ_DATA="$Base/Data/OutputData"
export OTS_SOURCE=$SPACK_ENV

echo -e "setup [${LINENO}]  \t Now your user data path is USER_DATA \t\t = \${USER_DATA}"
echo -e "setup [${LINENO}]  \t Now your database path is ARTDAQ_DATABASE_URI \t = \${ARTDAQ_DATABASE_URI}"
echo -e "setup [${LINENO}]  \t Now your output data path is OTSDAQ_DATA \t = \${OTSDAQ_DATA}"
echo

alias kx='ots -k'

echo
echo -e "setup [${LINENO}]  \t Now use 'ots --wiz' to configure otsdaq"
echo -e "setup [${LINENO}]  \t  	Then use 'ots' to start otsdaq"
echo -e "setup [${LINENO}]  \t  	Or use 'ots --help' for more options"
echo
echo -e "setup [${LINENO}]  \t     use 'kx' to kill otsdaq processes"
echo

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
    

spack concretize --force && spack install -j $BUILD_J
if [[ ${opt_develop:-0} -eq 1 ]];then
	spack env deactivate
	spack mpd init -r site -u $Base/spack-repos/mpd
	spack mpd new-project --name ots-develop -E ots-${demo_version} cxxstd=20 %gcc@13.1.0 --force -y
	spack install cetmodules@3.26.00 # Needed for now
	spack env activate ots-develop
	spack add cetmodules@3.26.00
	spack concretize --force
	spack mpd build
	installStatus=$?
fi

installStatus=$?

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

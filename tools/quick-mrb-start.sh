#! /bin/bash
# quick-mrb-start.sh - Eric Flumerfelt, May 20, 2016
# Downloads otsdaq_demo as an MRB-controlled repository

git_status=`git status 2>/dev/null`
git_sts=$?
if [ $git_sts -eq 0 ];then
    echo "This script is designed to be run in a fresh install directory!"
    exit 1
fi


starttime=`date`
Base=$PWD
test -d products || mkdir products
test -d download || mkdir download
test -d log || mkdir log

env_opts_var=`basename $0 | sed 's/\.sh$//' | tr 'a-z-' 'A-Z_'`_OPTS
USAGE="\
   usage: `basename $0` [options] [demo_root]
examples: `basename $0` .
          `basename $0` --run-ots
          `basename $0` --debug
If the \"demo_root\" optional parameter is not supplied, the user will be
prompted for this location.
--run-ots     runs otsdaq
--debug       perform a debug build
--develop     Install the develop version of the software (may be unstable!)
--tag         Install a specific tag of otsdaq
-v            Be more verbose
-x            set -x this script
-w            Check out repositories read/write
"

# Process script arguments and options
eval env_opts=\${$env_opts_var-} # can be args too
eval "set -- $env_opts \"\$@\""
op1chr='rest=`expr "$op" : "[^-]\(.*\)"`   && set -- "-$rest" "$@"'
op1arg='rest=`expr "$op" : "[^-]\(.*\)"`   && set --  "$rest" "$@"'
reqarg="$op1arg;"'test -z "${1+1}" &&echo opt -$op requires arg. &&echo "$USAGE" &&exit'
args= do_help= opt_v=0; opt_w=0; opt_develop=0;
while [ -n "${1-}" ];do
    if expr "x${1-}" : 'x-' >/dev/null;then
        op=`expr "x$1" : 'x-\(.*\)'`; shift   # done with $1
        leq=`expr "x$op" : 'x-[^=]*\(=\)'` lev=`expr "x$op" : 'x-[^=]*=\(.*\)'`
        test -n "$leq"&&eval "set -- \"\$lev\" \"\$@\""&&op=`expr "x$op" : 'x\([^=]*\)'`
        case "$op" in
            \?*|h*)     eval $op1chr; do_help=1;;
            v*)         eval $op1chr; opt_v=`expr $opt_v + 1`;;
            x*)         eval $op1chr; set -x;;
			w*)         eval $op1chr; opt_w=`expr $opt_w + 1`;;
            -tag)     eval $op1arg; tag=$1; shift;;
            -run-ots)  opt_run_ots=--run-ots;;
	    -debug)     opt_debug=--debug;;
			-develop) opt_develop=1;;
            *)          echo "Unknown option -$op"; do_help=1;;
        esac
    else
        aa=`echo "$1" | sed -e"s/'/'\"'\"'/g"` args="$args '$aa'"; shift
    fi
done
eval "set -- $args \"\$@\""; unset args aa
set -u   # complain about uninitialed shell variables - helps development

test -n "${do_help-}" -o $# -ge 2 && echo "$USAGE" && exit

# JCF, 1/16/15
# Save all output from this script (stdout + stderr) in a file with a
# name that looks like "quick-start.sh_Fri_Jan_16_13:58:27.script" as
# well as all stderr in a file with a name that looks like
# "quick-start.sh_Fri_Jan_16_13:58:27_stderr.script"
alloutput_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4".script"}' )
stderr_file=$( date | awk -v "SCRIPTNAME=$(basename $0)" '{print SCRIPTNAME"_"$1"_"$2"_"$3"_"$4"_stderr.script"}' )
exec  > >(tee "$Base/log/$alloutput_file")
exec 2> >(tee "$Base/log/$stderr_file")

function detectAndPull() {
	local startDir=$PWD
	cd $Base/download
	local packageName=$1
	local packageOs=$2
    if [[ "$packageOs" != "noarch" ]]; then
	    local packageOsArch="$2-x86_64"
	    packageOs=`echo $packageOsArch|sed 's/-x86_64-x86_64/-x86_64/g'`
    fi

	if [ $# -gt 2 ];then
		local qualifiers=$3
		if [[ "$qualifiers" == "nq" ]]; then
			qualifiers=
		fi
	fi
	if [ $# -gt 3 ];then
		local packageVersion=$4
	else
		local packageVersion=`curl http://scisoft.fnal.gov/scisoft/packages/${packageName}/ 2>/dev/null|grep ${packageName}|grep "id=\"v"|tail -1|sed 's/.* id="\(v.*\)".*/\1/'`
	fi
	local packageDotVersion=`echo $packageVersion|sed 's/_/\./g'|sed 's/v//'`

	if [[ "$packageOs" != "noarch" ]]; then
		local upsflavor=`ups flavor`
		local packageQualifiers="-`echo $qualifiers|sed 's/:/-/g'`"
		local packageUPSString="-f $upsflavor -q$qualifiers"
	fi
	local packageInstalled=`ups list -aK+ $packageName $packageVersion ${packageUPSString-}|grep -c "$packageName"`
	if [ $packageInstalled -eq 0 ]; then
		local packagePath="$packageName/$packageVersion/$packageName-$packageDotVersion-${packageOs}${packageQualifiers-}.tar.bz2"
		wget http://scisoft.fnal.gov/scisoft/packages/$packagePath >/dev/null 2>&1
		local packageFile=$( echo $packagePath | awk 'BEGIN { FS="/" } { print $NF }' )

		if [[ ! -e $packageFile ]]; then
			if [[ "$packageOs" == "slf7-x86_64" ]]; then
				# Try sl7, as they're both valid...
				detectAndPull $packageName sl7-x86_64 ${qualifiers:-"nq"} $packageVersion
			else
				echo "Unable to download $packageName"
				return 1
			fi
		else
			local returndir=$PWD
			cd $Base/products
			tar -xjf $Base/download/$packageFile
			cd $returndir
		fi
	fi
	cd $startDir
}

cd $Base/download

echo "Cloning cetpkgsupport to determine current OS"
git clone http://cdcvs.fnal.gov/projects/cetpkgsupport
os=`./cetpkgsupport/bin/get-directory-name os`

# Get all the information we'll need to decide which exact flavor of the software to install
notag=0
if [ -z "${tag:-}" ]; then 
  tag=develop;
  notag=1;
fi
wget https://cdcvs.fnal.gov/redmine/projects/otsdaq/repository/demo/revisions/$tag/raw/ups/product_deps
demo_version=`grep "parent otsdaq_demo" $Base/download/product_deps|awk '{print $3}'`
if [ $notag -eq 1 ];then
  tag=$demo_version
fi
otsdaq_version=`grep "^otsdaq " $Base/download/product_deps | awk '{print $2}'`
utilities_version=`grep "^otsdaq_utilities " $Base/download/product_deps | awk '{print $2}'`
defaultQuals=`grep "defaultqual" $Base/download/product_deps|awk '{print $2}'`
equalifier=`echo $defaultQuals|cut -f1 -d:`
squalifier=`echo $defaultQuals|cut -f2 -d:`

if [[ -n "${opt_debug:-}" ]] ; then
    build_type="debug"
else
    build_type="prof"
fi

wget http://scisoft.fnal.gov/scisoft/bundles/tools/pullProducts
chmod +x pullProducts
## TODO: Autodetect artdaq_demo bundle version!
./pullProducts $Base/products ${os} artdaq_demo-v2_09_00 ${squalifier}-${equalifier} ${build_type}
    if [ $? -ne 0 ]; then
	echo "Error in pullProducts."
	exit 1
    fi
detectAndPull mrb noarch
detectAndPull xerces_c ${os}-x86_64 e10:${build_type} v3_1_3
rm -rf *.bz2 *.txt
source $Base/products/setup
setup mrb
setup git
setup gitflow
setup nodejs v4_5_0

export MRB_PROJECT=otsdaq_demo
cd $Base
mrb newDev -f -v $demo_version -q ${equalifier}:${squalifier}:${build_type}
set +u
source $Base/localProducts_otsdaq_demo_${demo_version}_${equalifier}_${squalifier}_${build_type}/setup
set -u

cd $MRB_SOURCE
if [[ $opt_develop -eq 1 ]]; then
if [ $opt_w -gt 0 ];then
mrb gitCheckout -d otsdaq_utilities ssh://p-otsdaq@cdcvs.fnal.gov/cvs/projects/otsdaq-utilities
mrb gitCheckout ssh://p-otsdaq@cdcvs.fnal.gov/cvs/projects/otsdaq
mrb gitCheckout -d otsdaq_demo ssh://p-otsdaq@cdcvs.fnal.gov/cvs/projects/otsdaq-demo
else
mrb gitCheckout -d otsdaq_utilities http://cdcvs.fnal.gov/projects/otsdaq-utilities
mrb gitCheckout http://cdcvs.fnal.gov/projects/otsdaq
mrb gitCheckout -d otsdaq_demo http://cdcvs.fnal.gov/projects/otsdaq-demo
fi
else
if [ $opt_w -gt 0 ];then
mrb gitCheckout -t ${otsdaq_version} -d otsdaq ssh://p-otsdaq@cdcvs.fnal.gov/cvs/projects/otsdaq
mrb gitCheckout -t ${utilities_version} -d otsdaq_utilities ssh://p-otsdaq@cdcvs.fnal.gov/cvs/projects/otsdaq-utilities
mrb gitCheckout -t ${demo_version} -d otsdaq_demo ssh://p-otsdaq@cdcvs.fnal.gov/cvs/projects/otsdaq-demo
else
mrb gitCheckout -t ${otsdaq_version} -d otsdaq http://cdcvs.fnal.gov/projects/otsdaq
mrb gitCheckout -t ${utilities_version} -d otsdaq_utilities http://cdcvs.fnal.gov/projects/otsdaq-utilities
mrb gitCheckout -t ${demo_version} -d otsdaq_demo http://cdcvs.fnal.gov/projects/otsdaq-demo
fi
fi
cp -a $MRB_SOURCE/otsdaq_demo/NoGitDataDemo $MRB_SOURCE/otsdaq_demo/NoGitData

cd $Base/products
for file in $Base/srcs/otsdaq_demo/tarballs/*.bz2;do tar -xf $file;done

cd $Base
    cat >setupOTSDAQDEMO <<-EOF
	echo # This script is intended to be sourced.

	sh -c "[ \`ps \$\$ | grep bash | wc -l\` -gt 0 ] || { echo 'Please switch to the bash shell before running the otsdaq-demo.'; exit; }" || exit

	source $Base/products/setup
        setup mrb
        setup git
        source $Base/localProducts_otsdaq_demo_${demo_version}_${equalifier}_${squalifier}_${build_type}/setup
        source mrbSetEnv

        export CETPKG_INSTALL=$Base/products
	export CETPKG_J=16


        export USER_DATA="$MRB_SOURCE/otsdaq_demo/NoGitData"


        #export OTSDAQ_REPO="$MRB_SOURCE/otsdaq"
        #export FHICL_FILE_PATH=.:\$OTSDAQ_REPO/tools/fcl:\$FHICL_FILE_PATH
        #export OTSDAQDEMO_BUILD="$MRB_BUILDDIR/build_otsdaq_demo"        
        #export OTSDAQDEMO_REPO="$MRB_SOURCE/srcs/otsdaq_demo"
        #export OTSDAQ_BUILD="$MRB_BUILDDIR/build_otsdaq"
        #export OTSDAQUTILITIES_BUILD="$MRB_BUILDDIR/build_otsdaq_utilities"
        #export OTSDAQUTILITIES_REPO="$MRB_SOURCE/srcs/otsdaq_utilities"

	alias rawEventDump="art -c $MRB_SOURCE/otsdaq/artdaq-ots/ArtModules/fcl/rawEventDump.fcl"
        alias kx='killall -9 xdaq.exe; killall -9 mpirun; killall -9 mf_rcv_n_fwd'
       
        echo
        echo "Now use 'StartOTS.sh' to start otsdaq"
        echo " Or use 'StartOTS.sh --wiz' to configure otsdaq"
        echo
        echo "    use 'kx' to kill otsdaq processes"
  
	EOF
    #

# Build artdaq_demo
cd $MRB_BUILDDIR
set +u
source mrbSetEnv
set -u
export CETPKG_J=$((`cat /proc/cpuinfo|grep processor|tail -1|awk '{print $3}'` + 1))
mrb build    # VERBOSE=1
installStatus=$?

if [ $installStatus -eq 0 ]; then
    echo "otsdaq-demo has been installed correctly. Use 'source setupOTSDAQDEMO; StartOTS.sh' to start the software"
    echo
else
    echo "BUILD ERROR!!! SOMETHING IS VERY WRONG!!!"
    echo
fi

endtime=`date`

echo "Build start time: $starttime"
echo "Build end time:   $endtime"


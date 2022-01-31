echo # This script is intended to be sourced.

sh -c "[ `ps $$ | grep bash | wc -l` -gt 0 ] || { echo 'Please switch to the bash shell before running the otsdaq-demo.'; exit; }" || exit

echo -e "setup[${LINENO}]: \t ====================================================="
echo -e "setup[${LINENO}]: \t Initially your products path was PRODUCTS=${PRODUCTS}"

shopt -s expand_aliases #allows for aliases in non-interactive mode (which apparently is critical depending on the temperment of the terminal)

#unalias because the original VM aliased for users
unalias ots >/dev/null 2>&1

unsetup_all >/dev/null 2>&1
unset PRODUCTS
unset MRB_SOURCE

#PRODUCTS_SAVE=${PRODUCTS:+${PRODUCTS}}\:/data-08/otsdaq/localProducts_otsdaq_demo__s64_e15_prof:/data-08/products
#PRODUCTS=${PRODUCTS:+${PRODUCTS}}${PRODUCTS_SAVE:+\:${PRODUCTS_SAVE}}
#PRODUCTS=/data/ups
PRODUCTS=${PWD}/products
#PRODUCTS=/cvmfs/fermilab.opensciencegrid.org/products/artdaq
source ${PRODUCTS}/setup
PRODUCTS=${PWD}/products:/cvmfs/fermilab.opensciencegrid.org/products/artdaq


setup mrb
setup git
source ${PWD}/localProducts_*/setup
mrbsetenv
echo -e "setup[${LINENO}]: \t Now your products path is PRODUCTS=${PRODUCTS}"
echo

ulimit -c unlimited

# Setup environment when building with MRB (As there's no setupARTDAQOTS file)

#export OTSDAQ_DEMO_LIB=${MRB_BUILDDIR}/otsdaq_demo/lib
#export OTSDAQ_LIB=${MRB_BUILDDIR}/otsdaq/lib
#export OTSDAQ_UTILITIES_LIB=${MRB_BUILDDIR}/otsdaq_utilities/lib
#Done with Setup environment when building with MRB (As there's no setupARTDAQOTS file)

#set number of cores used for compiling, if needed
if [ "x$CETPKG_J" == "x" ]; then
	export CETPKG_J=8
fi

#setup ninja generator
#============================
ninjaver=`ups list -aK+ ninja|sort -V|tail -1|awk '{print $2}'|sed 's|"||g'`
setup ninja $ninjaver
#Note: functions survive scripting chaos better than aliases!
unalias makeninja >/dev/null 2>&1
function makeninja
{	pushd $MRB_BUILDDIR; ninja -j $CETPKG_J; popd; }
# alias makeninja='pushd $MRB_BUILDDIR; ninja -j $CETPKG_J; popd'
unalias mz >/dev/null 2>&1
function mz
{	mrb z; mrbsetenv; mrb b --generator ninja; }
# alias mz='mrb z; mrbsetenv; mrb b --generator ninja'
unalias mb >/dev/null 2>&1
function mb
{	makeninja; }
# alias mb='makeninja'
export OTS_DISABLE_TRACE_DEFAULT=1


export OTS_MAIN_PORT=2015

export USER_DATA="${MRB_SOURCE}/otsdaq_demo/NoGitData"
export ARTDAQ_DATABASE_URI="filesystemdb://${MRB_SOURCE}/otsdaq_demo/NoGitDatabases/filesystemdb/test_db"
export OTSDAQ_DATA="${MRB_SOURCE}/otsdaq_demo/NoGitData/OutputData"

echo -e "setup[${LINENO}]: \t Now your user data path is USER_DATA \t\t = ${USER_DATA}"
echo -e "setup[${LINENO}]: \t Now your database path is ARTDAQ_DATABASE_URI \t = ${ARTDAQ_DATABASE_URI}"
echo -e "setup[${LINENO}]: \t Now your output data path is OTSDAQ_DATA \t = ${OTSDAQ_DATA}"
echo

unalias rawEventDump >/dev/null 2>&1
function rawEventDump
{	art -c ${PWD}/srcs/otsdaq/artdaq-ots/ArtModules/fcl/rawEventDump.fcl; }
# alias rawEventDump="art -c ${PWD}/srcs/otsdaq/artdaq-ots/ArtModules/fcl/rawEventDump.fcl"

unalias kx >/dev/null 2>&1
function kx
{	
	echo -e "setup[${LINENO}]: \t Executing ots kill-all..."
	ots -k; 

    #now hard kill any processes that may be stuck and detached:

	killall -9 art &>/dev/null 2>&1 #hide output
	killall -9 boardreader &>/dev/null 2>&1 #hide output
	killall -9 eventbuilder &>/dev/null 2>&1 #hide output
	killall -9 datalogger &>/dev/null 2>&1 #hide output
	killall -9 dispatcher &>/dev/null 2>&1 #hide output
	killall -9 routing_master &>/dev/null 2>&1 #hide output
	ipcrm -a &>/dev/null 2>&1 #hide output #clean-up shared memory
	
	#kills self too:
	killall -9 ots &>/dev/null 2>&1 #hide output
	killall -9 xdaq.exe  &>/dev/null 2>&1 #hide output
	killall -9 otsConsoleFwd  &>/dev/null 2>&1 #hide output

	echo -e "setup[${LINENO}]: \t Done with ots kill-all."
}
# alias kx='ots -k'

unalias UpdateOTS.sh >/dev/null 2>&1
function UpdateOTS.sh
{	${MRB_SOURCE}/otsdaq_utilities/tools/UpdateOTS.sh $@; }
# alias UpdateOTS.sh='${MRB_SOURCE}/otsdaq_utilities/tools/UpdateOTS.sh'

echo
echo -e "setup[${LINENO}]: \t Now use 'ots --wiz' to configure otsdaq in wiz(safe) mode"
echo -e "setup[${LINENO}]: \t         'ots' to start otsdaq in normal mode"
echo -e "setup[${LINENO}]: \t         'ots --help' for more options"
echo
echo -e "setup[${LINENO}]: \t         'kx' to kill all otsdaq processes"
echo -e "setup[${LINENO}]: \t         'mz' for clean build"
echo -e "setup[${LINENO}]: \t         'mb' for incremental build"
echo -e "setup[${LINENO}]: \t         'UpdateOTS.sh' for update options"
echo




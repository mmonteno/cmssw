#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function die { echo Failure $1: status $2 ; rm -rf $3/{ramdisk,data,*.py}; exit $2 ; }

if [ -z  $LOCAL_TEST_DIR ]; then
LOCAL_TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi
echo "LOCAL_TEST_DIR = $LOCAL_TEST_DIR"

if [ -z  $LOCAL_TMP_DIR ]; then
LOCAL_TMP_DIR="/tmp"
fi
echo "LOCAL_TMP_DIR = $LOCAL_TMP_DIR"

cd $LOCAL_TEST_DIR

RC=0
P=$$
PREFIX=results_${USER}${P}
OUTDIR=${LOCAL_TMP_DIR}/${PREFIX}
echo "Output will be temporarily written to ${OUTDIR}"

mkdir ${OUTDIR}
cp ${SCRIPTDIR}/startBU.py ${OUTDIR}
cp ${SCRIPTDIR}/startFU.py ${OUTDIR}
cd ${OUTDIR}

rm -rf $OUTDIR/{ramdisk,data,*.log}
echo "Running test with index JSONs"
CMDLINE_STARTBU="cmsRun startBU.py runNumber=101 fffBaseDir=${OUTDIR} maxLS=2 fedMeanSize=128 eventsPerFile=11 eventsPerLS=35 frdFileVersion=0"
CMDLINE_STARTFU="cmsRun startFU.py runNumber=101 fffBaseDir=${OUTDIR}"
${CMDLINE_STARTBU} > out_1_bu.log 2>&1 || die "${CMDLINE_STARTBU}" $? $OUTDIR
${CMDLINE_STARTFU} > out_1_fu.log 2>&1 || die "${CMDLINE_STARTFU}" $? $OUTDIR


rm -rf $OUTDIR/{ramdisk,data}


echo "Running test with FRD file header (no index JSONs)"
CMDLINE_STARTBU="cmsRun startBU.py runNumber=101 fffBaseDir=${OUTDIR} maxLS=2 fedMeanSize=128 eventsPerFile=11 eventsPerLS=35 frdFileVersion=1"
CMDLINE_STARTFU="cmsRun startFU.py runNumber=101 fffBaseDir=${OUTDIR}"
${CMDLINE_STARTBU}  > out_2_bu.log 2>&1 || die "${CMDLINE_STARTBU}" $? $OUTDIR
${CMDLINE_STARTFU}  > out_2_fu.log 2>&1 || die "${CMDLINE_STARTFU}" $? $OUTDIR


#no failures, clean up everything including logs if there are no errors
rm -rf $OUTDIR/{ramdisk,data,*.py,*.log}

exit ${RC}

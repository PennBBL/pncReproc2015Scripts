#!/bin/bash
# ---------------------------------------------------------------
# PCASL_QUANT.sh - calcualte CBF map from pCASL data
#
# M. Elliott - 6/2013

# --------------------------
Usage() {
	echo "usage: `basename $0` <4Dinput> LabelTime DelayTime SliceTime <maskfile> <3Dresult> [BloodT1]"
	echo "    or"
	echo "       `basename $0` <4Dinput> <XMLfile> <maskfile> <3Dresult> [BloodT1]"
	echo " "
	echo "  args:"
	echo "          <4Dinput>       4D NIFTI with pCASL control/tag pairs"
	echo "          <XMLfile>       XML file with header info from pCASL Dicom file (made with dicom_dump.sh)"
	echo "          <maskfile>      3D NIFTI with pixel mask for analysis"
	echo "          <3Dresult>      filename root for result 3D NIFTI with CBF values"
	echo "  notes:"
	echo "          maskfile = '0'           determine mask with 3dAutomask"
	echo "          BloodT1  = 0 or <empty>  use BloodT1 = $BloodT1 (msec)"
	echo "          BloodT1  = #             use provided # (msec)"
	echo "          BloodT1  = -1            compute T1 based on age and gender (requires XML file)"
	echo "          BloodT1  < -1            compute T1 using Hematocrit, where HCT = |BloodT1| (in %)"
    exit 1
}
# --------------------------

# --- Get/Set fixed params ---
Labeleff=0.85
BloodT1=1664
lambda=0.9;    # *1000*6000 ->  mL/g

# --- Perform standard script startup code ---
OCD=${PWD}; EXECDIR=`dirname $0`; cd ${EXECDIR}; EXECDIR=${PWD}; cd ${OCD}   # get absolute path to this script
source /home/melliott/scripts/qa_preamble.sh

#### AFGR TESTING HERE #######
echo "$@"
echo "$#"

# --- Parse inputs ---
if [ $# -lt 4 -o $# -gt 7 ]; then Usage; fi
xmlfile=""
infile=`imglob -extension $1`
echo
echo
echo $infile
echo 
echo
if [ "X${infile}" == "X" ]; then echo "ERROR: $1 doesn't exist!"; exit 1; fi
indir=`dirname $infile`
inbase=`basename $infile`
inroot=`remove_ext $inbase`
    xmlfile=$2
    maskfile=$3
    resultfile=$4
    bloodt1_in=${5}
outdir=`dirname $resultfile`
outbase=`basename $resultfile`
outroot=`remove_ext $outbase`

#### AFGR TESTING HERE #######


# --- Get sequence params from XML file (made from call to dicom_dump.sh) ---
if [ ! -f ${xmlfile} ]; then echo "ERROR: $xmlfile doesn't exist!"; exit 1; fi
if [ "X${xmlfile}" != "X" ]; then
    echo "Reading XMLfile..."
    line=`grep -iw WIPMEMBLOCK_DVAL_02 $xmlfile`;            a=(`echo $line | tr "><" "\n"`);        delay=${a[2]}       # label delay (usec)
    line=`grep -iw WIPMEMBLOCK_DVAL_03 $xmlfile`;            a=(`echo $line | tr "><" "\n"`);        nrf=${a[2]}         # num RF blocks
    line=`grep -iw ECHOTIME $xmlfile`;                       a=(`echo $line | tr "><" "\n"`);        te=${a[2]}          
    line=`grep -iw ACQUISITIONMATRIX $xmlfile`;              a=(`echo $line | tr "><" "\n"`);        np=${a[6]}          # Y voxels in recon image
    if [ $np -eq 0 ]; then a=(`echo $line | tr "><," "\n"`); np=${a[6]}; fi
    if [ $np -eq 0 ]; then echo "ERROR: cannot parse $xmlfile for npoints!"; exit 1; fi
    line=`grep -iw BANDWIDTHPERPIXELPHASEENCODE $xmlfile`;   a=(`echo $line | tr "><" "\n"`);        bw=${a[2]}          
    line=`grep -iw NUMBEROFPHASEENCODINGSTEPS $xmlfile`;     a=(`echo $line | tr "><" "\n"`);        ny=${a[2]}          # ny phase encode (includes partial fourier)
    line=`grep -iw PATMODETEXT $xmlfile`;                    a=(`echo $line | tr "><" "\n"`);        ipat=${a[2]}          
    line=`grep -iw PATIENTBIRTHDATE $xmlfile`;               a=(`echo $line | tr "><" "\n"`);        dob=${a[2]}          
    line=`grep -iw STUDYDATE $xmlfile`;                      a=(`echo $line | tr "><" "\n"`);        scandate=${a[2]}          
    line=`grep -iw PATIENTSEX $xmlfile`;                     a=(`echo $line | tr "><" "\n"`);        gender=${a[2]}          
 
    # cleanup values
    delay=`echo "$delay" | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}'`  # need to handle possible expontial notation!!
    ipat=`echo $ipat | tr "p" " "`
    [ $gender = "F" ] ; sex=$?

    # --- do math to get sequence dependent params ---
    ESP=`echo "scale=8; 1/($bw*$np) * $ipat * 1000" | bc`           # echo-spacing (msec)
    Slicetime=`echo "scale=4; $te + ($ESP*$ny/$ipat/2)" | bc`       # TE + 1/2 of echo-train time (msec)
    Labeltime=`echo "scale=4; $nrf * 18.4" | bc`                    # msec
    Delaytime=`echo "scale=4; $delay * 0.001" | bc`                 # usec -> msec
    scanyear=`echo "scale=0; $scandate/10000" | bc`                 # year of scan
    birthyear=`echo "scale=0; $dob/10000" | bc`                     # year of birth
    age=`echo "scale=0; $scanyear-$birthyear" | bc`                 # age at scan
    echo $age
    echo $age
    echo $age
    echo "complete age testing"
if [ "X" == "Y" ]; then
echo "te = $te"
echo "np = $np"
echo "bw = $bw"
echo "ny = $ny"
echo "ipat = $ipat"
echo "dob = $dob"  
echo "scandate = $scandate"
echo "gender = $gender"  
echo "sex = $sex"  
echo "ESP = $ESP"  
echo "age = $age"  
fi
fi

# --- Set Blood T1 ---
case $bloodt1_in in 
     0)   ;;    # use default already set
     
    -1)   if [ "X${xmlfile}" != "X" ]; then
            echo "Computing Blood T1 from age = $age and sex = $sex"
            BloodT1=`echo "scale=6; 2115.6 - 21.5*$age - 73.3*$sex" | bc`   # % msec (from Jain paper)
          else
            echo "ERROR! Age dependent Blood T1 calc requires XMLfile."; exit 1 
          fi
          ;;
          
    -*)   HCT=`echo "scale=6; $bloodt1_in * -1" | bc`
          echo "Computing Blood T1 from HCT = $HCT%"
          BloodT1=`echo "scale=6; 1000/(0.52 * $HCT/100 + 0.38)" | bc`
          ;;
          
     *)   BloodT1=$bloodt1_in ;;    # use provided value
esac
echo "Using: LabelTime = $Labeltime  DelayTime = $Delaytime  SliceTime = $Slicetime  BloodT1 = $BloodT1"

# --- Make voxel mask ---
if [ ${maskfile} = "0" ]; then
    echo "Automasking..." 
    maskfile=${indir}/${inroot}_mask.nii
    rm -f $maskfile
    3dAutomask -prefix $maskfile $infile  2>/dev/null
fi

# --- Split 4D into label/control pairs ---
echo "Splitting Labels and Controls..."
labelfile=${indir}/${inroot}_labels.nii
controlfile=${indir}/${inroot}_controls.nii
rm -f $labelfile $controlfile
3dcalc -prefix $labelfile   -a $infile'[0..$(2)]' -expr "a" 2>/dev/null   # even volumes = labels
3dcalc -prefix $controlfile -a $infile'[1..$(2)]' -expr "a" 2>/dev/null # odd volumes = controls

# --- find any zeros in control images to avoid divide by zero ---
echo "Masking for Control zeros..."
cmaskfile=${indir}/${inroot}_controlmask.nii
fmaskfile=${indir}/${inroot}_cbfmask.nii
fslmaths $controlfile -Tmin -bin $cmaskfile
fslmaths $maskfile -mul $cmaskfile $fmaskfile

# --- Compute pairs of (controls-labels)/controls ---
echo "Computing difference pairs..."
difffile=${indir}/${inroot}_diff.nii
rm -f ${indir}/${inroot}_diff.nii
3dcalc -datum float -prefix $difffile -m $fmaskfile -l $labelfile -c $controlfile -expr 'ispositive(m)*(c-l)/c' 2>/dev/null

# --- Make image of slice times ---
echo "Computing slice times..."
timefile=${indir}/${inroot}_slicetime.nii
rm -f $timefile
3dcalc -datum float -prefix $timefile -m $fmaskfile -expr "$Slicetime*k + $Delaytime" 2>/dev/null # use built-in z-index "k"

# --- Compute CBF using params ---
echo "Computing CBF map..."
factorfile=${indir}/${inroot}_cbffactor.nii
rm -f $factorfile
3dcalc -datum float -prefix $factorfile -t $timefile -expr "(6000*1000*$lambda/$BloodT1)/(2*$Labeleff * (exp(-t/$BloodT1) - exp(-(t+$Labeltime)/$BloodT1)))" 2>/dev/null 

cbfpairsfile=${indir}/${inroot}_cbfpairs.nii
rm -f $cbfpairsfile
3dcalc -datum float -prefix $cbfpairsfile -c $factorfile -d $difffile -expr "c*d" 2>/dev/null 

fslmaths $cbfpairsfile -Tmean $resultfile

# --- Save info in log file ---
logfile=${outdir}/${outroot}.log
echo -e "modulename\t$0"      > $logfile
echo -e "version\t$VERSION"  >> $logfile
echo -e "inputfile\t$infile" >> $logfile
echo -e "Labeltime\t$Labeltime" >> $logfile
echo -e "Delaytime\t$Delaytime" >> $logfile
echo -e "Slicetime\t$Slicetime" >> $logfile
echo -e "BloodT1\t$BloodT1" >> $logfile

# --- clean up ---
#if [ $keep -eq 0 ]; then 
#    imrm $indir/${inroot}_labels $indir/${inroot}_controls $indir/${inroot}_slicetime $indir/${inroot}_controlmask $indir/${inroot}_cbffactor $indir/${inroot}#_cbfpairs $indir/${inroot}_diff
#fi
exit 0


#!/bin/bash
# ---------------------------------------------------------------
# DICO_B0CALC.sh
#
# Calculate B0 map from double echo Siemens fieldmap sequence
# Uses FSL and AFNI to convert Dicom images to NIFTI format
# Images are phase unwrapped and in units of Hertz
#
# Created: M Elliott 1/2010
# ---------------------------------------------------------------

# --- print how to call this thing ---
Usage() {
cat << EOF
Usage:
       `basename $0` [-dukxmFS2ch] outfile_root magnitude_dicom_folder/ phase_dicom_folder/ 
   or  `basename $0` [-dukxmFS2ch] outfile_root mag_dcm1 mag_dcm2 ... mag_dcmN phase_dcm1 phase_dcm2 ... phase_dcmN
   
Mask options:
       `basename $0` -s [-f BET_f] [-g BET_g]        make brain mask using FSL's "bet"         
   or  `basename $0` -a                              make brain mask using AFNI's "3dAutomask"
   or  `basename $0` -A                              make brain mask using Stathis's "antsBrainExtraction.sh" script
   or  `basename $0` -T T1head.nii -B T1brain.nii    use existing brain mask in T1 space
   or  `basename $0` -b brainmask.nii                use existing brain mask already in b0map space

Other options:
    -f  Set BET command "f" value (default = ${bet_f})
    -g  Set BET command "g" value (default = ${bet_g})
    -d  De_oblique using AFNI "3dWarp" (default = OFF)
    -u  Use "dcm2nii" for Nifti conversion (default = OFF, use AFNI "to3d" instead)
    -m  Remove mean value from resulting fieldmap (i.e. rpsmap.nii) (default = OFF)
    -x  Remove spikes from the edges of the fieldmap (i.e. rpsmap.nii) (default = OFF)
    -F  Force Nifti results to be RPI orientation
    -S  Sort dicom files by series and instance number
    -k  Keep intermediate files (default = OFF)
    -2  Compute T2* map (default = OFF)
    -c  add a comment string to the NIFTI descip field (example: -c 'my comment')
    -h  Print this Help info			
EOF
exit 1
}

# ---------------------------------------------------------------
# Remove mean from image (lifted from FSL5 fsl_prepare_fieldmap)
demean_image() {
  # demeans image
  # args are: <image> <mask>
  infile=$1
  maskim=$2
  outfile=$3
  tmpnm=`$FSLDIR/bin/tmpnam`
  $FSLDIR/bin/fslmaths ${infile} -mas ${maskim} ${tmpnm}_tmp_fmapmasked
  $FSLDIR/bin/fslmaths ${infile} -sub `$FSLDIR/bin/fslstats ${tmpnm}_tmp_fmapmasked -k ${maskim} -P 50` -mas ${maskim} ${outfile} -odt float
  rm -rf ${tmpnm}_tmp_*
}
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# Despike edges (lifted from FSL5 fsl_prepare_fieldmap)
clean_up_edge() {
    # does some despiking filtering to clean up the edge of the fieldmap
    # args are: <fmap> <mask> <tmpnam>
    infile=$1
    maskim=$2
    outfile=$3
    tmpnm=`$FSLDIR/bin/tmpnam`
    $FSLDIR/bin/fugue --loadfmap=${infile} --savefmap=${tmpnm}_tmp_fmapfilt --mask=${maskim} --despike --despikethreshold=2.1
    $FSLDIR/bin/fslmaths ${maskim} -kernel 2D -ero ${tmpnm}_tmp_eromask 
    $FSLDIR/bin/fslmaths ${maskim} -sub ${tmpnm}_tmp_eromask -thr 0.5 -bin ${tmpnm}_tmp_edgemask 
    $FSLDIR/bin/fslmaths ${tmpnm}_tmp_fmapfilt -mas ${tmpnm}_tmp_edgemask ${tmpnm}_tmp_fmapfiltedge
    $FSLDIR/bin/fslmaths ${infile} -mas ${tmpnm}_tmp_eromask -add ${tmpnm}_tmp_fmapfiltedge ${outfile}
    rm -rf ${tmpnm}_tmp_*
}
# ---------------------------------------------------------------

# --- Set AFNI/FSL stuff ---
export FSLOUTPUTTYPE=NIFTI
export AFNI_AUTOGZIP=NO
export AFNI_COMPRESSOR=

# --- set defaults ---
de_oblique=0        # NOTE: This can be used if b0map or epi is obliqued
use_dcm2nii=0	    # Use dcm2nii to make Niftis
do_skullstrip=0	    # Skull-strip magnitude B0map image
do_automask=0	    # use 3dAutomask on magnitude B0map image
do_ANTSmask=0       # Use ANTS antsBrainExtraction.sh to mask
keep_files=0        # keep intermediate files around (for debugging)
do_demean=0         # de-mean the rpsmap
do_despike=0        # de-spike the rpsmap
force_RPI=0         # force result to be RPI
bet_f="0.3"         # BET command f-factor
bet_g="0.0"         # BET comand g-factor
t1whole=""          # whole brain T1 structural
t1brain=""          # brain extracted T1 structural
brainmask=""        # mask for brain in fmap space
do_filesort=0       # sort the dicoms according to series and slice number
do_t2star=0         # compute t2star map
comment=""          # pass comment string to dicom2nifti.sh for putting into NIFTI header
opterr=0

#--- Parse command line switches ---
while getopts "T:B:b:f:g:c:saASdumkhFx2" Option
do
  case $Option in
	T ) t1whole=$OPTARG;;
	B ) t1brain=$OPTARG;;
	b ) brainmask=$OPTARG;;
	f ) bet_f=$OPTARG;;
	g ) bet_g=$OPTARG;;
	s ) do_skullstrip=1;;
	a ) do_automask=1;;
	A ) do_ANTSmask=1;;
	S ) do_filesort=1;;
	m ) do_demean=1;;
	x ) do_despike=1;;
	d ) de_oblique=1;;
	k ) keep_files=1;;
	F ) force_RPI=1;;
	u ) use_dcm2nii=1;;
	2 ) do_t2star=1;;
	c ) comment=$OPTARG;;
	h ) opterr=1;;	 # "-h" option used for help
	* ) opterr=1;;   # unrecognized.
  esac
done
shift $(($OPTIND - 1))

# --- Check command line ---
if [ $# -lt 3 -o $opterr -eq 1 ]; then Usage; fi

# --- Check for conflicts of switches ---
[ -z $t1whole ]   ; use_t1whole=$?;
[ -z $brainmask ] ; use_brainmask=$?;
Nmaskopts=$(($do_skullstrip + $do_automask + $do_ANTSmask + $use_t1whole + $use_brainmask))
if [ $Nmaskopts -gt 1 ];                            then echo "ERROR: You can only choose ONE of -s, -a, -A, -b, or -T"; exit 1; fi
if [ -n "$t1whole" -a -z "$t1brain" ];              then echo "ERROR: If you provide a T1head you MUST also provide a skull-stripped T1brain"; exit 1; fi
if [ -n "$t1brain" -a -z "$t1whole" ];              then echo "ERROR: If you provide a skull-stripped T1brain you MUST also provide a T1head"; exit 1; fi
if [ -n "$t1whole" -a ! -e "$t1whole" ];            then echo "ERROR: $t1whole does not exist"; exit 1; fi
if [ -n "$t1brain" -a ! -e "$t1brain" ];            then echo "ERROR: $t1brain does not exist"; exit 1; fi
if [ -n "$brainmask" -a ! -e "$brainmask" ];        then echo "ERROR: $brainmask does not exist"; exit 1; fi

# --- Figure out path to other scripts in same place as this one ---
EXECDIR=`dirname $0`
if [ "X${EXECDIR}" != "X" ]; then
    OCD=$PWD; cd ${EXECDIR}; EXECDIR=${PWD}/; cd $OCD # makes path absolute
fi

# --- Get command line stuff ---
outfroot=`remove_ext $1`
shift

# --- Get input Dicom or folders with Dicoms ---        
if [ $# -eq 2 ]; then
    echo "Two series folders provided. Getting dicom file names."
    dcmfiles=( `ls ${1}/*.dcm ${2}/*.dcm` )
else
    dcmfiles=( $@ )
fi
ndcm=${#dcmfiles[@]}
if [ $ndcm == "0" ]; then echo "ERROR: No files matching *.dcm found in $1 and $2"; exit 1; fi

# --- Determine if this is the Siemens "gre_field_mapping" sequence ---
! (dicom_hdr -sexinfo ${dcmfiles[0]} 2> /dev/null | grep "tSequenceFileName" | grep -q "gre_field_mapping") 
is_siemens_fieldmap=$?
if [ $is_siemens_fieldmap -eq 1 ]; then
    echo "These images are from the Siemens gre_field_mapping sequence. File sorting will be forced."
    do_filesort=1
fi

# --- Sort files by series, echo and image number ----
if [ $do_filesort -eq 1 ]; then
    echo "Sorting dicom file by series, echo and image number..."
    ${EXECDIR}dicom_sort.sh -get_series_info ${dcmfiles[@]} > ${outfroot}_sortresult.txt
    if [ $? -ne 0 ]; then echo "ERROR: Sort failed."; exit 1; fi 
    dcmfiles=(`head -n 1 ${outfroot}_sortresult.txt | tail -n 1`)       # get 1st line of result, which is the sorted filenames
    seriesinfo=(`head -n 2 ${outfroot}_sortresult.txt | tail -n 1`)     # 2nd line is series info
    
    nseries=${seriesinfo[1]}
    if [ $nseries -ne 2 ]; then echo "ERROR: Found $nseries series. Expecting exactly 2."; exit 1; fi 
    series1_count=${seriesinfo[2]}
    series2_count=${seriesinfo[3]}

  echo "Found series split of ${series1_count}/${series2_count} files."
  if [ $is_siemens_fieldmap -eq 1 ]; then
    if [ $series1_count -eq $series2_count ]; then # dicoms were renamed so as to overwrite one of the magnitude volumes! 
        echo "ERROR: Siemens gre_fieldmapping sequence should make 2 magnitude and 1 phase volumes! Possible file renaming error?"
        exit 1
#        echo "Will expect only one magnitude and one phase volume!"
#        is_siemens_fieldmap=2 
    fi 
  fi         
fi

# --- check number of dicoms make sense, and split into mag & phase volumes ---
maglist1=""; maglist2=""; phalist1=""; phalist2="";
case $is_siemens_fieldmap in
    # Double echo GRE
    0)  if [ $ndcm -lt 64 ]; then echo "ERROR: Only found $ndcm files. Expected at least 64."; exit 1; fi
        rem=$(( $ndcm % 4 ))                                                              
        if [ $rem -ne 0 ]; then echo "ERROR: Found $ndcm dicom files. $ndcm is not divisible by 4. Missing some files?"; exit 1; fi
        echo "Dividing $ndcm dicom files into mag1, mag2, phase1, phase2 sets."
        nz=$(( $ndcm / 4 ))
        nz2=$(( $nz * 2 ))
        nz3=$(( $nz * 3 ))
        nz4=$(( $nz * 4 ))
        for (( i=0;   i<$nz;  i++ )) ; do maglist1="$maglist1 ${dcmfiles[$i]}"; done
        for (( i=nz;  i<$nz2; i++ )) ; do maglist2="$maglist2 ${dcmfiles[$i]}"; done
        for (( i=nz2; i<$nz3; i++ )) ; do phalist1="$phalist1 ${dcmfiles[$i]}"; done
        for (( i=nz3; i<$nz4; i++ )) ; do phalist2="$phalist2 ${dcmfiles[$i]}"; done        
        ;;

   # Siemens gre_fieldmapping w/ 2 mag and 1 phase volumes
    1)  if [ $ndcm -lt 48 ]; then echo "ERROR: Only found $ndcm files. Expected at least 48."; exit 1; fi
        rem=$(( $ndcm % 3 ))                                                              
        if [ $rem -ne 0 ]; then echo "ERROR: Found $ndcm dicom files. $ndcm is not divisible by 3. Missing some files?"; exit 1; fi
        echo "Dividing $ndcm dicom files into mag1, mag2, phase1 sets."
        nz=$(( $ndcm / 3 ))
        nz2=$(( $nz * 2 ))
        nz3=$(( $nz * 3 ))
        for (( i=0;   i<$nz;  i++ )) ; do maglist1="$maglist1 ${dcmfiles[$i]}"; done
        for (( i=nz;  i<$nz2; i++ )) ; do maglist2="$maglist2 ${dcmfiles[$i]}"; done
        for (( i=nz2; i<$nz3; i++ )) ; do phalist1="$phalist1 ${dcmfiles[$i]}"; done
        ;;

    # Siemens gre_fieldmapping w/ missing magnitude volume
    2)  if [ $ndcm -lt 32 ]; then echo "ERROR: Only found $ndcm files. Expected at least 64."; exit 1; fi
        rem=$(( $ndcm % 2 ))                                                              
        if [ $rem -ne 0 ]; then echo "ERROR: Found $ndcm dicom files. $ndcm is not divisible by 2. Missing some files?"; exit 1; fi
        echo "Dividing $ndcm dicom files into mag1, phase1 sets."
        nz=$(( $ndcm / 2 ))
        nz2=$(( $nz * 2 ))
        for (( i=0;  i<$nz;  i++ )) ; do maglist1="$maglist1 ${dcmfiles[$i]}"; done
        for (( i=nz; i<$nz2; i++ )) ; do phalist1="$phalist1 ${dcmfiles[$i]}"; done
        ;;
esac

# --- convert to Niftis ---
options=""
if [ $use_dcm2nii -eq 1 ]; then options=u${options}; fi
if [ $de_oblique  -eq 1 ]; then options=d${options}; fi
if [ $keep_files  -eq 1 ]; then options=k${options}; fi
if [ $force_RPI   -eq 1 ]; then options=F${options}; fi
if [ X$options != "X"   ]; then options=-${options}; fi
options="${options} -r N"    # need to ignore any Dicom scaling settings
${EXECDIR}dicom2nifti.sh $options ${outfroot}_mag1.nii $maglist1;         if [ $? -eq 1 ]; then exit 1; fi 
${EXECDIR}dicom2nifti.sh $options ${outfroot}_pha1.nii $phalist1 ;        if [ $? -eq 1 ]; then exit 1; fi
if [ $is_siemens_fieldmap -ne 2 ]; then
    ${EXECDIR}dicom2nifti.sh $options ${outfroot}_mag2.nii $maglist2 ;    if [ $? -eq 1 ]; then exit 1; fi
fi
if [ $is_siemens_fieldmap -eq 0 ]; then
    ${EXECDIR}dicom2nifti.sh $options ${outfroot}_pha2.nii $phalist2 ;    if [ $? -eq 1 ]; then exit 1; fi
fi

# --- get TEs of each image ---
if [ $is_siemens_fieldmap -eq 2 ]; then
    dTE=2.65
    echo "Assuming dTE = $dTE (msec)"
else
    dcminfo=(`dicom_hdr ${dcmfiles[0]} 2>/dev/null | grep -i "echo time"`) 
    np=${#dcminfo[@]}
    TE1=`echo ${dcminfo[$np-1]} | tr -d 'Time//'`
    dcminfo=(`dicom_hdr ${dcmfiles[$nz]} 2>/dev/null | grep -i "echo time"`) 
    np=${#dcminfo[@]}
    TE2=`echo ${dcminfo[$np-1]} | tr -d 'Time//'`
    dTE=`echo "scale=4; $TE2 - $TE1" | bc`	# do floating point math using "bc" command
    echo "TE1 = $TE1, TE2 = $TE2, dTE = $dTE (msec)"
    dTE_bad=`echo "$dTE <= 0" | bc`         # need to use bc to do fractional number compare
    if [ $dTE_bad -eq 1 ]; then
#        dTE=0.800
#        echo "dTE is <= zero. Assuming it is $dTE (msec)"
        echo "ERROR: $dTE is <= 0!" >&2
        exit 1
    fi
fi    

# --- Get shim current values used for this acq ---
rm -f b0map.shims
${EXECDIR}dicom_get_shim.sh ${dcmfiles[0]} > ${outfroot}_shims.txt

# --- find out if this is bipolar or monopolar multi-echo GRE ---
dcminfo=(`dicom_hdr -sexinfo ${dcmfiles[0]} 2> /dev/null | grep -i "readoutmode"`) 
np=${#dcminfo[@]}
ReadOutMode=${dcminfo[$np-1]}
if [ $ReadOutMode = "0x1" ]; then
    readout="monopolar"
	echo "monopolar read-out: OK"
elif [ $ReadOutMode = "0x2" ]; then
    readout="bipolar"
	echo "bipolar read-out: OK"
#	echo "ERROR: bipolar read-out: don't know how to deal with this" >&2
#	exit 1
else
	echo "ERROR: unrecognized read-out mode" >&2
	exit 1
fi

# ------------------ BRAIN MASKING ----------------------------
# --- Coregister whole brain struct to fmap magnitude image ---
if [ -n "$t1whole" ]; then
	echo "Coregistering T1head to B0map magnitude image."
    T1orient=`@GetAfniOrient $t1whole 2> /dev/null`
    B0orient=`@GetAfniOrient ${outfroot}_mag1.nii 2>/dev/null`
    if [ $T1orient != $B0orient ]; then
        echo "ERROR: T1head orientation ($T1orient) does not match b0map orientation ($B0orient). Don't want to flirt them." >&2
        exit 1
    fi
    flirt -in $t1whole -ref ${outfroot}_mag1 -o ${outfroot}_t1head_in_fmap  -omat ${outfroot}_t1_to_fmap.mat -dof 6 
    flirt -in $t1brain -ref ${outfroot}_mag1 -o ${outfroot}_t1brain_in_fmap -init ${outfroot}_t1_to_fmap.mat -applyxfm -interp nearestneighbour
    fslmaths ${outfroot}_t1brain_in_fmap -bin ${outfroot}_brainmask
    fslmaths ${outfroot}_mag1 -mas ${outfroot}_brainmask ${outfroot}_mag1_brain
    MAGFILE=${outfroot}_mag1_brain.nii
    MASKFILE=${outfroot}_brainmask.nii
    
# --- skull strip with BET ---
elif [ $do_skullstrip = "1" ]; then
	echo "Skull stripping with BET (-f = ${bet_f} -g = ${bet_g})."
	bet ${outfroot}_mag1 ${outfroot}_mag1_brain -f ${bet_f} -g ${bet_g} -R
	fslmaths ${outfroot}_mag1_brain -bin ${outfroot}_brainmask
	MAGFILE=${outfroot}_mag1_brain.nii
    MASKFILE=${outfroot}_brainmask.nii

# --- skull strip with AFNI ---
elif [ $do_automask = "1" ]; then
	echo "Making mask with 3dAutomask."
	rm -f ${outfroot}_brainmask.nii
	3dAutomask -clfrac 0.68 -prefix ${outfroot}_brainmask.nii ${outfroot}_mag1.nii 2>/dev/null
    fslmaths ${outfroot}_mag1 -mas ${outfroot}_brainmask ${outfroot}_mag1_brain
	MAGFILE=${outfroot}_mag1_brain.nii
    MASKFILE=${outfroot}_brainmask.nii

# --- Use provided brain mask ---
elif [ -n "$brainmask" ]; then
    fslmaths ${outfroot}_mag1 -mas $brainmask ${outfroot}_mag1_brain
    MAGFILE=${outfroot}_mag1_brain.nii
    MASKFILE=$brainmask

# --- Use Stathis' ANTs based approach ---
elif [ $do_ANTSmask = "1" ]; then
	echo "Making mask with antsBrainExtraction.sh"
    if [ -z $FSLDIR ]; then echo "ERROR: FSLDIR environment not set. Can't find FSL brain templates."; exit 1; fi
    fslhead=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz
    fslbrain=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask.nii.gz
    antsBrainExtraction.sh -a ${outfroot}_mag1.nii -e $fslhead -m $fslbrain -o ${outfroot}_antsBE &> /dev/null
    if [ $? -ne 0 ]; then echo "ERROR: cant find ANTS"; exit 1; fi
    gunzip ${outfroot}_antsBEBrainExtractionBrain.nii.gz
    gunzip ${outfroot}_antsBEBrainExtractionMask.nii.gz
    mv -f ${outfroot}_antsBEBrainExtractionBrain.nii ${outfroot}_mag1_brain.nii
    mv -f ${outfroot}_antsBEBrainExtractionMask.nii ${outfroot}_brainmask.nii
    rmdir ${outfroot}_antsBE
	MAGFILE=${outfroot}_mag1_brain.nii
    MASKFILE=${outfroot}_brainmask.nii

# --- No brain mask desired, use raw magnitude fmap ---
else
	MAGFILE=${outfroot}_mag1.nii
	MASKFILE=""     # no explicit brain mask, let prelude choose its own mask later
fi

# --- Compute fieldmap ---
echo "Calculating fieldmap."

# --- Convert integer Dicom phase images to radians ---
# --- (Note: FSL's prelude doesn't care if maps are [0,2pi] or [-pi,pi])
imrm fmap_rad1 fmap_rad2
if [ $is_siemens_fieldmap -eq 0 ]; then
  if [ $readout = "monopolar" ]; then
    fslmaths ${outfroot}_pha1 -mul 3.14159 -div 2048 -sub 3.14159 ${outfroot}_rad1 -odt float
    fslmaths ${outfroot}_pha2 -mul 3.14159 -div 2048 -sub 3.14159 ${outfroot}_rad2 -odt float
  else
    fslmaths ${outfroot}_pha1 -mul 3.14159 -div 2048 -sub 3.14159 ${outfroot}_rad1 -odt float
#    fslmaths ${outfroot}_pha2 -mul 3.14159 -div 2048 -sub 3.14159 ${outfroot}_rad2 -odt float
    fslmaths ${outfroot}_pha2 -mul 3.14159 -div 2048 -sub 3.14159 ${outfroot}_rad2raw -odt float
    NP=`fslval ${outfroot}_rad2raw dim1`
    3dcalc -a ${outfroot}_rad2raw.nii -expr "(i-$NP/2-1)*3.14159/$NP/2" -prefix ${outfroot}_rad2err.nii &> /dev/null   # this is the error in rad2 due to bipolar readout
    fslmaths ${outfroot}_rad2raw -sub ${outfroot}_rad2err ${outfroot}_rad2
  fi
else # Siemens gre_fieldmapping already gives delta_phase map 
    fslmaths ${outfroot}_pha1 -mul 3.14159 -div 2048 -sub 3.14159 ${outfroot}_dradx -odt float
fi

# --- compute complex ratio of TE1 and TE2 images ---
# --- doing only one Prelude call works better (less wrap boundary errors) ---
# --- Use AFNI because "fslcomplex" has some bug which switches A->P ---
if [ $is_siemens_fieldmap -eq 0 ]; then
    rm -f ${outfroot}_a.nii ${outfroot}_b.nii ${outfroot}_c.nii ${outfroot}_d.nii ${outfroot}_dradx.nii
    3dcalc -a $MAGFILE -b ${outfroot}_rad1.nii -expr 'a*cos(b)' -prefix ${outfroot}_a.nii -datum float &> /dev/null
    3dcalc -a $MAGFILE -b ${outfroot}_rad1.nii -expr 'a*sin(b)' -prefix ${outfroot}_b.nii -datum float &> /dev/null
    3dcalc -a $MAGFILE -b ${outfroot}_rad2.nii -expr 'a*cos(b)' -prefix ${outfroot}_c.nii -datum float &> /dev/null
    3dcalc -a $MAGFILE -b ${outfroot}_rad2.nii -expr 'a*sin(b)' -prefix ${outfroot}_d.nii -datum float &> /dev/null
    3dcalc -a ${outfroot}_a.nii -b ${outfroot}_b.nii -c ${outfroot}_c.nii -d ${outfroot}_d.nii -expr '-atan2(b*c-a*d,a*c+b*d)' -prefix ${outfroot}_dradx.nii -datum float &> /dev/null
fi

# --- Unwrap delta_phase image ---
prelude_option=""
if [ "X$MASKFILE" != "X" ]; then prelude_option="--mask=$MASKFILE"; fi
cmd="prelude -a $MAGFILE -p ${outfroot}_dradx -o ${outfroot}_drad_unwrap $prelude_option --savemask=${outfroot}_mask"
echo "Running command:"
echo "  $cmd"
eval $cmd
if [ $? -ne 0 ]; then echo "ERROR: Prelude error - try not using the -u option to this script." >&2; exit 1; fi # possibly "scl_slope" = 2 in Nifti header

# --- compare to FSL's recommended method: separately unwrap, then subtract phase maps ---
# --- CONCLUSION: same result but better to do only one PRELUDE ---
#rm -f fmap_rad1_unwrap.nii fmap_rad2_unwrap.nii b0mapX.nii radmapX.nii
#prelude -v -a $MAGFILE -p fmap_rad1 -o fmap_rad1_unwrap 
#prelude -v -a $MAGFILE -p fmap_rad2 -o fmap_rad2_unwrap 
#fslmaths fmap_rad2_unwrap -sub fmap_rad1_unwrap -mul 1000 -div $dTE -div 6.28318 hzmapX - odt float	# x1000/msec/2/PI = Hz
#fslmaths fmap_rad2_unwrap -sub fmap_rad1_unwrap -mul 1000 -div $dTE              rpsmapX -odt float	# x1000/msec = rad/sec

# --- Convert phase difference image to Hz and radians/sec ---
#fslmaths ${outfroot}_drad_unwrap -mul 1000 -div $dTE -div 6.28318 ${outfroot}_hzmap  -odt float	# x1000/msec/2/PI = Hz
fslmaths ${outfroot}_drad_unwrap  -mul 1000 -div $dTE              ${outfroot}_rpsmap -odt float	# x1000/msec = radians/sec

# --- Use FUGUE to fill holes ---
immv ${outfroot}_rpsmap ${outfroot}_rpsmap_prefill; fugue --loadfmap=${outfroot}_rpsmap_prefill --mask=${outfroot}_mask         --savefmap=${outfroot}_rpsmap
immv ${outfroot}_mask   ${outfroot}_mask_prefill;   fugue --loadfmap=${outfroot}_mask_prefill   --mask=${outfroot}_mask_prefill --savefmap=${outfroot}_mask

# --- Remove mean from rpsmap ---
if [ $do_demean = "1" ]; then
	echo "De-meaning rpsmap."
	immv ${outfroot}_rpsmap ${outfroot}_rpsmap_nzmean
	demean_image ${outfroot}_rpsmap_nzmean ${outfroot}_mask ${outfroot}_rpsmap
fi

# --- Remove spikes from the edges of the rpsmap ---
if [ $do_despike = "1" ]; then
	echo "De-spiking edges of rpsmap."
	immv ${outfroot}_rpsmap ${outfroot}_rpsmap_predespike
	clean_up_edge ${outfroot}_rpsmap_predespike ${outfroot}_mask ${outfroot}_rpsmap
fi

# --- Compute T2* map from 2 magntiude images ---
if [ $do_t2star = "1" ]; then
    if [ $is_siemens_fieldmap -eq 2 ]; then	
        echo "Cannot compute T2* map from single magnitude gre_fieldmapping data. Ignoring this option."
    else 
        echo "Computing T2* map."
#        fslmaths ${outfroot}_mag1 -s 3 -mas ${outfroot}_mask_prefill -log  ${outfroot}_mag1_log -odt float
#        fslmaths ${outfroot}_mag2 -s 3 -mas ${outfroot}_mask_prefill -log  ${outfroot}_mag2_log -odt float
#        fslmaths ${outfroot}_mag1_log -sub ${outfroot}_mag2_log -div $dTE -recip ${outfroot}_t2star -odt float

        ${EXECDIR}t2map.sh ${outfroot}_mag1 ${outfroot}_mag2 $dTE ${outfroot}_mask_prefill 3 ${outfroot}_t2star

#        fslmaths ${outfroot}_mag1 -s 3 ${outfroot}_mag1_sm # another way to do the same math
#        fslmaths ${outfroot}_mag2 -s 3 ${outfroot}_mag2_sm
#        fslmaths ${outfroot}_mag1_sm3 -div ${outfroot}_mag2_sm3 -mas ${outfroot}_mask_prefill -log -div $dTE -recip ${outfroot}_t2star2
    fi
fi

# --- Add decsriptive comment to NIFTIs we made ---
if [ "X${comment}" != "X" ]; then
    ${EXECDIR}nifti_set_descrip.sh ${outfroot}_mag1   "$comment"
    ${EXECDIR}nifti_set_descrip.sh ${outfroot}_pha1   "$comment"
    ${EXECDIR}nifti_set_descrip.sh ${outfroot}_rpsmap "$comment"
    ${EXECDIR}nifti_set_descrip.sh ${outfroot}_mask   "$comment"
    ${EXECDIR}nifti_set_descrip.sh ${outfroot}_mag2   "$comment"    2> /dev/null  # these files not guaranteed to exist, so ignore error
    ${EXECDIR}nifti_set_descrip.sh ${outfroot}_t2star "$comment"    2> /dev/null
    ${EXECDIR}nifti_set_descrip.sh ${outfroot}_pha2   "$comment"    2> /dev/null
fi

# --- clean up ---
if [ $keep_files -eq 0 ]; then
    rm -f ${outfroot}_filelist.txt ${outfroot}_sortlist.txt ${outfroot}_cutlist.txt
	rm -f ${outfroot}_mag1.log ${outfroot}_mag2.log ${outfroot}_pha1.log ${outfroot}_pha2.log
	rm -f ${outfroot}_t1_to_fmap.mat
    imrm ${outfroot}_rad2err ${outfroot}_rad2raw
	imrm ${outfroot}_a ${outfroot}_b ${outfroot}_c ${outfroot}_d
#    imrm ${outfroot}_mag2 
    imrm ${outfroot}_mag1_log ${outfroot}_mag2_log ${outfroot}_mag1_sm ${outfroot}_mag2_sm
	imrm ${outfroot}_brainmask ${outfroot}_rad1 ${outfroot}_rad2 ${outfroot}_pha1 ${outfroot}_pha2 ${outfroot}_dradx ${outfroot}_drad_unwrap
	imrm ${outfroot}_rpsmap_nzmean ${outfroot}_rpsmap_predespike ${outfroot}_rpsmap_prefill ${outfroot}_mask_prefill ${outfroot}_t1head_in_fmap ${outfroot}_t1brain_in_fmap 
    #rm -f ${outfroot}_mag1_brain.nii # keep brain extracted mag image, if any
fi

echo "Done."
exit 0

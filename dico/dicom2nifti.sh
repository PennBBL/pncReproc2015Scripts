#!/bin/bash
# ---------------------------------------------------------------
# DICOM2NIFTI.sh
#
# Script to make Dicom files into 3D or 4D Nifti.
# Designed to handle obliques, including when mosaiced.
# Also designed to force result to be RPI if requested.
#
# Notes on operation of this script:
# 1) Expects dicom filenames to be presorted into proper slice order
# 2) Expects dicom files to all be from SAME series
#
# ---------------------------------------------------------------
# Some observations regarding Dicom SCALE and INTERCEPT fields:
#
# DCM2NII
# -) dcm2nii leaves the raw pixel value alone, but sets the "scl_slope" and "scl_intercept" fields in the Nifti
# -) fslview (and most FSL programs??) applies the slope and intercept when processing the pixel data
# -) WARNING: for Siemens B0map phase data, this causes the range of pixels to double, upsetting PRELUDE
#
# TO3D
# -) if AFNI_DICOM_RESCALE=NO, then Dicom scaling vals are IGNORED, and scl_slope=1 and scl_intercept=0 in the Nifti
# -) if AFNI_DICOM_RESCALE=YES, then raw pixel values are changed/scaled, and then RECAST to INT16 data type(!!)
#      then scl_slope=1 and scl_intercept=0 in the Nifti!!
#
# ---------------------------------------------------------------
# Some observations regarding converting OBLIQUE Dicoms to Nifti:
#
#  TO3D
# -) to3d ONLY writes the correct oblique header in the Sform. So use "fslorient -copysform2qform" afterwards.
# -) to3d appears to IGNORE the "-orient" switch in writing the sform, so don't bother with that option.
# -) to3d writes RAI Niftis (for axials), see below on how to convert them to RPI (it's not easy!)
#
#  MRI_CONVERT (Doug Greve's program)
# -) makes the same Sform as to3d. Also puts same correct xform in the Qform. Also writes RAI for axial Dicoms.
#
#  DCM2NII
# -) dcm2nii writes the same Qform and Sform.
# -) writes RPI for axial dicoms by default, can be avoided with "-r N"
# -) when obliques are both 4D & Mosaic'd, dcm2nii (sometimes?) gets the xform WRONG (origins are incorrect).
#
#  3DRESAMPLE 
# -) Does not work correctly on Obliques!! (creates non-oblique result)
#
#  FSLVIEW
# -) FSLVIEW only reads the Sform
# 
#  FSLREORIENT2STD
# -) does NOT always make RPI! 
# -) it always preserves the determinant, so it makes RAI -> LPI, but leaves RPI unchanged!
# -) Jenkinson says FSL does NOT require that everything is RPI, as long as the header is right. (Not sure we believe that!).
#
# -) FSLSWAPDIM/FSLORIENT
#    This CAN solve the problem of converting RAI -> RPI
#    See Mark Jenkinson quote: https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1211&L=fsl&D=0&F=1972462314827522&X=3BDC5604F0033F900E&Y=kruparel%40mail.med.upenn.edu&P=224179
#
#  TAKE HOME MESSAGE:
# -) DCM2NII works sometimes, but seems to have errors with 4D mosiac'd oblique dicoms
# -) TO3D works always, but the sform needs to be copied to the qform. Also, to convert RAI -> RPI do the following:
#      fslreorient2std myRAIimage myLPIimage
#      fslswapdim myLPIimage -x y z myRPIimage  # WARNING: this intermediate result has inconsistent header/data!!
#      fslorient -swaporient myRPIimage         # This is correct and RPI
#
#
# Created: M Elliott 11/2012
#
# ---------------------------------------------------------------

# --- Set AFNI/FSL stuff ---
export FSLOUTPUTTYPE=NIFTI
export AFNI_AUTOGZIP=NO
export AFNI_COMPRESSOR=     # NOTE: This script has not been vetted for handling .nii.gz results!
export AFNI_DICOM_VERBOSE=YES
export AFNI_DICOM_RESCALE=NO # Ignores scale and intercept values in Dicom headers
export AFNI_DICOM_WINDOW=NO # As far as I can tell, this should NEVER be YES - causes very strange NIFTI
to3d_datum=""

# --- set defaults ---
de_oblique=0        # deoblique with AFNI 3dWarp
use_dcm2nii=0	    # Use dcm2nii to make Niftis
force_RPI=0         # force result to be RPI
keep_files=0        # keep intermediate files
timeshift=0         # perform slice time correction
make_exampledcm=0   # make an example dicom for later
multi_volume=0      # handle multi-volume, multi-series (e.g. concatenating DTI runs)
apply_scale=-1      # use or ignore presence of scale/intercept values in Dicom header
make_t2map=0        # use multi-echo data to make T2 or T2* map
comment=""          # comment string for header
opterr=0

#--- Parse command line switches ---
while getopts "r:c:duFktem2h" Option
do
  case $Option in
	d ) de_oblique=1;;
	u ) use_dcm2nii=1;;
	F ) force_RPI=1;;
	k ) keep_files=1;;
	t ) timeshift=1;;
	e ) make_exampledcm=1;;
	m ) multi_volume=1;;
	r ) ! [ "$OPTARG" = "y" -o "$OPTARG" = "Y" ] ; apply_scale=$? ;;             # apply_scale=$(($OPTARG = 1));;
	2 ) make_t2map=1;;
	c ) comment=$OPTARG;;
	h ) opterr=1;;	# "-h" option used for help
	* ) opterr=1;;   # unknown switch.
  esac
done
shift $(($OPTIND - 1))

# --- Parse remaining command line ---
if [ $# -lt 2 -o $opterr -eq 1 ]; then
cat << EOF
USAGE: `basename $0` [-duFtemkh] [-r Y/N] [-c 'comment'] outfile dcmfile1 [dcmfile2 ... dcmfileN]
   
OPTIONS:
    -d  De_oblique using AFNI "3dWarp". This creates a non-oblique result (default = OFF)
    -u  Use "dcm2nii" for conversion (default = OFF, use AFNI "to3d" instead)
    -F  Force result to be RPI orientation (default = OFF)
    -t  perform slice Timing correction with "3dTshift" (default = OFF)
    -e  make an Example dicom file (default = OFF)
    -m  handle multi-volume, multi-series (e.g. concatenating DTI runs). Requires -u option (default = OFF)
    -2  make T2 or T2star maps from multi-echo data. Requires -m option (default = OFF)
    -k  Keep intermediate files (default = OFF)
    -r  Rescale NIFTI using Dicom Rescale/Intercept fields (must set either "Y" or "N").
    -c  Add a comment to the NIFTI header (example: -c 'this is a comment')
    -h  Print this Help info			
EOF
	exit 1
fi

# --- Check for conflicting options ---
if [ $multi_volume = "1" -a $use_dcm2nii = "0" ]; then echo "ERROR: -m option requires -u option">&2; exit 1; fi
if [ $multi_volume = "0" -a $make_t2map  = "1" ]; then echo "ERROR: -2 option requires -m option">&2; exit 1; fi

# --- Figure out path to other scripts in same place as this one ---
EXECDIR=`dirname $0`
if [ "X${EXECDIR}" != "X" ]; then
    OCD=$PWD; cd ${EXECDIR}; EXECDIR=${PWD}/; cd $OCD # makes path absolute
fi

# --- Get output Nifti file name ---
outfroot=`remove_ext $1`
outdir=`dirname $1`          # stupid to3d can't have path in output filename
outfile=${outfroot}.nii      # complete result file, with path
outxfile=`basename $outfile` # stupid to3d can't have path in output filename              
logfile=${outfroot}.log
#logfile=/dev/null
if [ ! -d $outdir ]; then echo "ERROR: output folder $outdir/ does not exist!"; exit 1; fi

# --- Get input Dicom(s) ---        
shift
ndcms=$#
dcmfiles=($@)
dcmdir=`dirname ${dcmfiles[0]}`
dcmfname=`basename ${dcmfiles[0]}`      # removes any directory in front (leaves extension)
dcmfroot=${dcmfname%.*}                 # strips extension
dcmfext=`echo $dcmfname |awk -F . '{if (NF>1) {print $NF}}'` # gets the extension (or "" if none)

echo "-----------------------------------------------------" | tee $logfile
echo "Starting `basename $0` on `date`" | tee -a $logfile

# --- Check if Dicoms have scale/intercept fields ---
! (dicom_hdr ${dcmfiles[0]} | grep -q "Rescale Intercept") 2> /dev/null; is_Scaled=$?
if [ $is_Scaled -eq 1 ]; then
    echo "Dicom files contain Scale/Intercept values!"
    case "$apply_scale" in
        -1) echo "    ERROR: You must decide if you want to use or ignore them."
            echo "    Use either the '-r Y' or '-r N' option."
            exit 1
            ;;
        0)  echo "    You have chosen to ignore them."
            if [ $use_dcm2nii -eq 1 ]; then
                echo "    ERROR: You opted to use dcm2nii, which cannot ignore Scale/Intercept values."
                echo "    Try not using the '-u' flag, or choose '-r Y'."
                exit 1
            fi
            export AFNI_DICOM_RESCALE=NO    # this only affects to3d
            ;;
        1)  echo "    These values will be applied to the pixel data."
            export AFNI_DICOM_RESCALE=YES
            to3d_datum="-datum float"       # if to3d is used, better to make float output
            ;;
        *)  echo "    ERROR: funny value for -r option: $apply_scale"
    esac 
fi

# --- Convert dicoms using DCM2NII ---
if [ $use_dcm2nii = "1" -a $multi_volume = "0" ]; then
    echo "Converting $ndcms Dicoms with dcm2nii..." | tee -a $logfile
    tmproot=`echo $dcmfroot | sed 's/\.//g'`   # get expected result filename from dcm2nii ('.' are removed!)
	tmpfile=$dcmdir/$tmproot.nii                # have to anticipate dcm2nii's output filename (how annoying!)
	rm -f $tmpfile                 
	dcm2nii -g N -p N -d N -e N -i N -v N -f Y ${dcmfiles[*]} >> $logfile
	mv -f $tmpfile $outfile        
	if [ -e $dcmdir/$tmproot.bvec ]; then
	    echo "Renaming bval & bvec files." | tee -a $logfile
	    mv -f $dcmdir/$tmproot.bval ${outfroot}.bval
	    mv -f $dcmdir/$tmproot.bvec ${outfroot}.bvec
    fi	    

# --- Convert multiple volumes from multiple series with dcm2nii ---
# --- (This is primarily to get the bvec and bval files for concatenated DTI runs) ---
elif [ $use_dcm2nii = "1" -a $multi_volume = "1" ]; then
    echo "Converting $ndcms multi-volume, (possibly) multi-series Dicoms with dcm2nii..." | tee -a $logfile
    tmpdir=`mktemp -d`                              # make a temp working folder
    cp -f ${dcmfiles[*]} $tmpdir                    # need to operate on all dicoms in a single folder
    tmproot=`echo $dcmfroot | sed 's/\.//g'`       # get expected result filename from dcm2nii ('.' are removed!)
    dcm2nii -g N -p N -d N -e N -i N -v Y -f Y -r N $tmpdir/* >> $logfile  # NOTE -r switch, prevents multiple orientations and crops, but does not force RPI!!!
    niftis=(`ls $tmpdir/*.nii`)
    nvols=${#niftis[@]}
    echo "Converted $nvols volumes. Concatenating them..."
    fslmerge -t $outfroot ${niftis[@]}
	if [ -e $tmpdir/$tmproot.bvec ]; then
        echo "Concatenating bval & bvec files..." | tee -a $logfile
        paste --delimiters= $tmpdir/*.bval > ${outfroot}.bval   # this concatenates files by column (bingo!)
        paste --delimiters= $tmpdir/*.bvec > ${outfroot}.bvec
    fi
    rm -rf $tmpdir
    
# --- Convert using TO3D ---	
else
    echo "Converting $ndcms Dicoms with to3d..." | tee -a $logfile
    
    # --- get acq params from 1st dicom file ---
	! (dicom_hdr ${dcmfiles[0]} | grep -q "MOSAIC") 2> /dev/null   
	is_Mosaic=$?
	
	# --- convert 4D series of mosaiced dicoms ---
	if [ $is_Mosaic -eq 1 -a $ndcms -gt 1 ]; then
	    echo "Multiple mosaiced dicoms. This is a 4D timeseries." | tee -a $logfile
		
		dcminfo=(`dicom_hdr ${dcmfiles[0]} | grep -i "repetition time"`) 2> /dev/null
		np=${#dcminfo[@]}; TR=`echo ${dcminfo[$np-1]} | tr -d 'Time//'`		            # Get TR
		nlines=(`dicom_hdr -sexinfo ${dcmfiles[0]} | grep "\].dReadoutFOV" | wc -l`) 2> /dev/null
		let "NZ = $nlines"				                                                # Get number of mosaic slices
		rem=$(( $NZ % 2 ))                                                              # Get slice time ordering scheme
		SCHEME="altplus"
		if [ $rem -eq 0 ]; then
			SCHEME="alt+z2"
        fi		
		echo TR = $TR, NZ = $NZ, SCHEME = $SCHEME
		if [ $NZ -eq 1 ]; then
		    echo "ERROR: Found only 1 Mosaic slice. Probably moco_MPRAGE navigator with screwy Dicom headers? Try using the -u option." | tee -a $logfile
		    exit 1
		fi
		
		rm -f $outfile
		to3d -epan $to3d_datum -skip_outliers -session $outdir -prefix $outxfile -view orig -time:zt $NZ $ndcms $TR $SCHEME ${dcmfiles[*]} >> $logfile 2>&1

    # --- convert single volume or single 2D slice ---
    else
        echo "Non-mosaiced or only one dicom. This is a 2D slice or 3D volume." | tee -a $logfile
		rm -f $outfile
        to3d $to3d_datum -session $outdir -prefix $outxfile ${dcmfiles[*]} >> $logfile 2>&1
	fi
	
	# --- Copy sform to qform (to3d doesn't set qform correctly for obliques) ---
	echo "Copying Sform to Qform (needed for obliques)" | tee -a $logfile
	fslorient -copysform2qform $outfroot
fi
echo "Converted $ndcms Dicoms to Nifti file: $outfile" | tee -a $logfile

# --- perform slice timing correction ---
if [ $timeshift -eq 1 ]; then
    let "NZ = `fslval $outfroot dim3`"				                                          
	rem=$(( $NZ % 2 ))                                                              
	SCHEME="altplus"
	if [ $rem -eq 0 ]; then
		SCHEME="alt+z2"
    fi		
    echo "Slice time correcting data for tpattern = $SCHEME..." | tee -a $logfile
    mv -f $outfile ${outfroot}_noTshift.nii
    3dTshift -prefix $outfile -tpattern $SCHEME ${outfroot}_noTshift.nii >> $logfile 2>&1
fi

# --- Deoblique if requested ---
! (3dinfo $outfile | grep -q "Oblique") 2> /dev/null
is_Oblique=$?
if [ $de_oblique -eq 1 -a $is_Oblique -eq 0 ]; then
    echo "Data set is not oblique. Ignoring deoblique option." | tee -a $logfile
elif [ $de_oblique -eq 1 ]; then
    echo "Deobliquing data set..." | tee -a $logfile
    mv -f $outfile ${outfroot}_obl.nii
    3dWarp -deoblique -prefix $outfile ${outfroot}_obl.nii >> $logfile 2>&1
fi

# --- Convert result to RPI ---
if [ $force_RPI = "1" ]; then
    ${EXECDIR}force_RPI.sh $outfroot; if [ $? -ne 0 ]; then exit 1; fi
fi

# --- Make T2 or T2star map from multiecho data ---
if [ $make_t2map = "1" ]; then
    echo "Making T2 or T2star map..." | tee -a $logfile
    if [ $nvols -ne 2 ]; then
        echo "WARNING: $nvols volumes found. Can only make T2maps from 2 echo data." >&2
    else
        dcminfo=(`dicom_hdr ${dcmfiles[0]} 2>/dev/null | grep -i "echo time"`);  np=${#dcminfo[@]}; TE1=`echo ${dcminfo[$np-1]} | tr -d 'Time//'`
        n=$(expr $ndcms / $nvols)
        dcminfo=(`dicom_hdr ${dcmfiles[$n]} 2>/dev/null | grep -i "echo time"`); np=${#dcminfo[@]}; TE2=`echo ${dcminfo[$np-1]} | tr -d 'Time//'`    
        dTE=`echo "scale=4; $TE2 - $TE1" | bc`	
        echo "TE1 = $TE1, TE2 = $TE2, dTE = $dTE (msec)"
        dTE_bad=`echo "$dTE <= 0" | bc`         # need to use bc to do fractional number compare
        if [ $dTE_bad -eq 1 ]; then echo "ERROR: $dTE is <= 0!" >&2; exit 1; fi
        ${EXECDIR}t2map.sh $outfroot $dTE 0 3 ${outfroot}_map
    fi
fi

# --- make an example dicom file ---
if [ $make_exampledcm -eq 1 ]; then
    example_dicom=${outfroot}_exampledicom.DCM  # use CAPS for .dcm so it is not confused with input Dicoms
    echo "Making example dicom file $example_dicom" | tee -a $logfile
#    if [ -e $example_dicom ]; then
#        echo "WARNING: $example_dicom already exists! Not overwriting it." | tee -a $logfile
#    else
        cp -f ${dcmfiles[0]} $example_dicom
#    fi 
fi

# --- insert a comment in the descrip field ---
if [ "X${comment}" != "X" ]; then
#    nifti_tool -mod_hdr -mod_field descrip "$comment" -overwrite -infiles ${outfroot}.nii
    ${EXECDIR}nifti_set_descrip.sh ${outfroot} "$comment"
fi

# --- remove intermediate files ---
if [ $keep_files -eq 0 ]; then
    imrm ${outfroot}_noTshift ${outfroot}_obl
fi
echo "-----------------------------------------------------" | tee -a $logfile

exit 0

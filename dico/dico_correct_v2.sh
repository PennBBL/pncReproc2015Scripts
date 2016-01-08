#!/bin/bash
# ---------------------------------------------------------------
# DICO_CORRECT_v2.sh
#
# Use B0map from "dico_b0calc_v2.sh" to correct distortions in EPIs
#
# Created: M Elliott 1/2010
# ---------------------------------------------------------------

# --- print how to call this thing ---
Usage() {
cat << EOF
USAGE: 
`basename $0` -p/-n [-x|y|z] [-options] <outfile_root> <rpsmap> <maskmap> Dicom_folder/ 
	or
`basename $0` -p/-n [-x|y|z] [-options] <outfile_root> <rpsmap> <maskmap> dcm1 dcm2 ... dcmN
	or
`basename $0` -p/-n [-x|y|z] [-options] -e <example_dicom> <outfile_root> <rpsmap> <maskmap> <EPIfile>

OPTIONS w/ REQUIRED PARAMETERS:
    -e <dicom>        example dicom file from EPI data. Use this to correct a 3D or 4D Nifti data file.
    -f <magmap>       FLIRT coregister the b0map to the EPI using provided B0map magnitude image
    -U <undistorted>  FLIRT to an undistorted image on the same grid as the input image(s). Requires -f option.
    -s sigma          use "smooth3" option to Fugue with sigma (mm)
	
OPTIONS:
    -p	apply FUGUE correction in "+" direction (e.g. X+ or Y+) (one of -p or -n is REQUIRED)
    -n	apply FUGUE correction in "-" direction (e.g. X- or Y-) 
    -d	de_OBLIQUE using AFNI "3dWarp" (default = OFF)
    -u	use "dcm2nii" for Nifti conversion (default = OFF, use AFNI "to3d" instead)
    -m	motion correct EPIs first with mcflirt (default = OFF)
    -k	keep intermediate files (default = OFF)
    -F  Force Nifti conversion to make RPI orientation
    -S  Sort dicom files by series and instance number
    -E  Extend shiftmap outside mask
    -x|y|z  Specify direction of distortion (overrides auto choice of ROW or COL)
    
    -h	print this Help info			
EOF
exit 1
}

# --- Set AFNI/FSL defaults ---
export FSLOUTPUTTYPE=NIFTI
export AFNI_AUTOGZIP=NO
export AFNI_COMPRESSOR=

# --- Set defaults ---
use_dcm2nii=0		# Use dcm2nii to make Niftis
de_oblique=0    	# Use 3dWarp to regrid oblique acqusition
do_moco=0			# moco EPI timeseries w/ mcflirt
keep_files=0		# keep intermediate files around (for debugging)
example_dicom=""	# use an example dicom and 4D Nifti rather than convert a folder of EPIs to Nifti
magfile=""	        # magnitude b0map image for coregistration
undistfile=""       # alternate target for FLIRT
force_RPI=0         # force result to be RPI
do_smooth=0			# smooth3 option to FUGUE
unwarp_sign=0		# sign for fugue's "unwarpdir" (i.e. "+" or "-") 
do_filesort=0
extendshift=0       # do not extend shift map outside mask
distdir=0
opterr=0

#--- Parse command line switches ---
while getopts "f:U:e:s:dumkhFSpnExyz" Option
do
  case $Option in
	s ) do_smooth=$OPTARG;;
	d ) de_oblique=1;;
	u ) use_dcm2nii=1;;
	m ) do_moco=1;;
	k ) keep_files=1;;
    F ) force_RPI=1;;
	S ) do_filesort=1;;
	p ) unwarp_sign="+";;
	n ) unwarp_sign="-";;
	e ) example_dicom=$OPTARG;;
	f ) magfile=$OPTARG;;
	U ) undistfile=$OPTARG;;
	E ) extendshift=1;;
    x ) distdir="x";;
    y ) distdir="y";;
    z ) distdir="z";;
	h ) opterr=1;;	# "-h" option used for help
	* ) opterr=1;;   # Error, illegal option.
  esac
done
shift $(($OPTIND - 1))

# --- Figure out path to other scripts in same place as this one ---
EXECDIR=`dirname $0`
if [ "X${EXECDIR}" != "X" ]; then
    OCD=$PWD; cd ${EXECDIR}; EXECDIR=${PWD}/; cd $OCD # makes path absolute
fi

# --- Check command line ---
if [ $# -lt 4 -o $opterr -eq 1 ]; then Usage; fi
if [ ${unwarp_sign} == "0" ]; then echo "ERROR: You MUST choose either -p or -n"; exit 1; fi
outfile=$1
outdir=`dirname $outfile`
outfname=`basename $outfile`            # removes any directory in front (leaves extension)
outfroot=${outfname%.*}                 # strips extension
outfroot=${outdir}/${outfroot}          # put dir back in front
rpsfile=$2
maskfile=$3
shift; shift; shift

# --- check for exsitence of files ---
if [ ! -e $rpsfile ];  then echo "ERROR: $rpsfile does not exist"; exit 1; fi
if [ ! -e $maskfile ]; then echo "ERROR: $maskfile does not exist"; exit 1; fi
#if [ ! -e $magfile ];  then echo "ERROR: $magfile does not exist"; exit 1; fi
if [ ! -e $1 ];        then echo "ERROR: $1 does not exist"; exit 1; fi

# --- Work on 3D or 4D NIFTI, with example dicom file ---
is_nifti=`imtest $1`
if [ $is_nifti -eq 1 ]; then  
    if [ X$example_dicom == "X" ]; then echo "ERROR: example dicom file must be provided. Use option -e."; exit 1; fi
    inputfile=$1

# --- Work on dicoms ---
else 
    if [ -d $1 ]; then
        echo "Folder provided. Finding dicoms."
        dcmfiles=( `ls ${1}/*.dcm` )    
    else
        dcmfiles=( $@ )
    fi
    ndcm=${#dcmfiles[@]}
    if [ $ndcm == "0" ]; then echo "ERROR: No files matching *.dcm found in $1"; exit 1; fi    

    # --- Sort dicom files by series and image number ----
    if [ $do_filesort -eq 1 ]; then
        echo "Sorting dicom files by series and instance number."
        filelist=${outfroot}_filelist.txt
        rm -f $filelist ; touch $filelist
        for (( i=0;   i<$ndcm;  i++ )); do
            dcminfo=(`dicom_hdr ${dcmfiles[$i]} 2>/dev/null | grep "Series Number"`) 
            np=${#dcminfo[@]}
            snum=`echo ${dcminfo[$np-1]} | tr -d 'Number//'`
            dcminfo=(`dicom_hdr ${dcmfiles[$i]} 2>/dev/null | grep "Instance Number"`) 
            np=${#dcminfo[@]}
            inum=`echo ${dcminfo[$np-1]} | tr -d 'Number//'`
    
            xnum=$(( $snum * 1000 + $inum ))    # make an index to sort    
            echo "${dcmfiles[$i]} $xnum " >> $filelist
        done
        sortfile=${outfroot}_sortlist.txt; sort -n -k 2 $filelist > $sortfile             # sort by the column of "xnums"
        cutfile=${outfroot}_cutlist.txt; cut -f 1 --delimiter=" " $sortfile > $cutfile    # cut out the column sorted filenames
        dcmfiles=( `cat $cutfile` )
    fi

    # --- convert dicoms to Nifti ---
    options=""
    if [ $use_dcm2nii -eq 1 ]; then options=u${options}; fi
    if [ $de_oblique  -eq 1 ]; then options=d${options}; fi
    if [ $keep_files  -eq 1 ]; then options=k${options}; fi
    if [ $force_RPI   -eq 1 ]; then options=F${options}; fi
    if [ X$options != "X"   ]; then options=-${options}; fi
    ${EXECDIR}dicom2nifti.sh $options ${outfroot} ${dcmfiles[@]} ; if [ $? -eq 1 ]; then exit 1; fi
    inputfile=${outfroot}.nii
    example_dicom=${dcmfiles[0]}
fi

# --- Motion correct raw EPI data ---
if [ $do_moco = "1" ]; then
	echo "Motion correcting EPI images."
	rm -fr $inputfile_mc.mat
	mcflirt -rmsrel -rmsabs -in $inputfile -refvol 0 -out $inputfile_mc
	inputfile=$inputfile_mc.nii
fi

# --- get ACQ params ---
echo "Getting acq params from `basename $example_dicom`"
dcminfo=(`dicom_hdr -sexinfo $example_dicom 2>/dev/null | grep "sPat.lAccelFactPE"`)
np=${#dcminfo[@]}
GRAPPA=${dcminfo[$np-1]}
dcminfo=(`dicom_hdr -sexinfo $example_dicom 2>/dev/null | grep "lEchoSpacing"`)
if [ $? -eq 0 ] ; then	# ESP only stored in header for user-chosen ESP
	np=${#dcminfo[@]}
	ESP=${dcminfo[$np-1]}
	ESP=`echo "scale=6; $ESP /1000000" | bc`	# use 'bc' to do math - convert usec to sec
else
	dcminfo=(`dicom_hdr -sexinfo $example_dicom 2>/dev/null | grep "Pixel Bandwidth"`)
	np=${#dcminfo[@]}
	PBW=`echo ${dcminfo[$np-1]} | tr -d 'Bandwidth//'`
	echo PBW = $PBW
	ESP=`echo "scale=6; 1/$PBW + 0.000082" | bc`	# use 'bc' to do math - convert pixbw to esp in sec
fi									
ESP_COR=`echo "scale=6; $ESP/$GRAPPA" | bc`
dcminfo=(`dicom_hdr $example_dicom 2>/dev/null | grep -i "0018 1312"`)
np=${#dcminfo[@]}

# --- Get phase encode direction from dicom header ---
PEDIR=`echo ${dcminfo[$np-1]} | tr -d 'Direction//'`
! (dicom_hdr -sexinfo $example_dicom | grep -q "dInPlaneRot") 2> /dev/null
PEREVERSED=$?   # phase encoding direction is rotated (i.e. A->P becomes P->A) 

# --- Set direction of distortion from PE dir ---
if [ $distdir == "0" ]; then
    if [ $PEDIR = "ROW" ]; then
	    UNWARP_DIR="x"
    elif [ $PEDIR = "COL" ]; then
	    UNWARP_DIR="y"	
    else
	    echo "ERROR: Strange PEDIR value: $PEDIR"
	    exit 1
    fi

# --- Use distortion direction provided by user ---
else
    UNWARP_DIR=$distdir
fi

# --- Get size of EPI image in direction that is distorted ---
case $UNWARP_DIR in
    x ) NP=`fslval $inputfile dim1`;;
    y ) NP=`fslval $inputfile dim2`;;
    z ) NP=`fslval $inputfile dim3`;;
esac

# --- Set sign of distortion direction ---
if [ ${unwarp_sign} == "-" ]; then
	UNWARP_DIR=${UNWARP_DIR}${unwarp_sign}
fi	

echo NP = $NP, GRAPPA = $GRAPPA, PEDIR = $PEDIR, PEREVERSED = $PEREVERSED, ESP = $ESP, Grappa corrected ESP = $ESP_COR
echo "FSL FUGUE direction = $UNWARP_DIR"

# --- Get shim current values used for this acq ---
${EXECDIR}dicom_get_shim.sh $example_dicom > ${outfroot}_shims.txt

# --- coregister B0map to EPI ---
if [ X$magfile != "X" ]; then
    echo "Coregistering B0map to EPI image(s) using FLIRT."
    fslmaths $magfile -mas $maskfile ${outfroot}_magmap_masked  # make (hopefully) brain-masked b0map magnitude image
    if [ X$undistfile != "X" ]; then
        echo "    using undistorted image $undistfile as reference."
        flirt -ref $undistfile -in ${outfroot}_magmap_masked -dof 6 -omat ${outfroot}.mat -o ${outfroot}_magmap_coreg
    else
        flirt -ref $inputfile -in ${outfroot}_magmap_masked -dof 6 -omat ${outfroot}.mat -o ${outfroot}_magmap_coreg
    fi
    flirt -ref $inputfile -in $rpsfile -init ${outfroot}.mat -o ${outfroot}_rpsmap_coreg -applyxfm      #  regrid RPSmap to target epi

#    fugue --loadfmap=$rpsfile --mask=$maskfile --unmaskfmap --savefmap=${outfroot}_rpsmap_extended --unwarpdir=$UNWARP_DIR      # extrapolate b0map outside mask
#    flirt -ref $inputfile -in ${outfroot}_rpsmap_extended      -init ${outfroot}.mat -o ${outfroot}_rpsmap_coreg -applyxfm      # then regrid to target epi

    fslmaths ${outfroot}_magmap_coreg -bin ${outfroot}_rpsmap_mask_coreg
    rpsfile=${outfroot}_rpsmap_coreg.nii
    maskfile=${outfroot}_rpsmap_mask_coreg.nii
fi

# --- Check that voxel grids match and regrid if needed ---
EP_xform=`fslorient -getsform $inputfile`      # get xform
B0_xform=`fslorient -getsform $rpsfile`
EP_xform=`printf "%1.1f " $EP_xform`            # set precision for our comparison
B0_xform=`printf "%1.1f " $B0_xform`
EP_xform=${EP_xform//-0.0/0.0}                  # remove problematic "-0.0" strings
B0_xform=${B0_xform//-0.0/0.0}
EP_xform="$EP_xform `fslval $inputfile dim1` `fslval $inputfile dim2` `fslval $inputfile dim3`"      # append matrix size
B0_xform="$B0_xform `fslval $rpsfile dim1` `fslval $rpsfile dim2` `fslval $rpsfile dim3`"
#echo $EP_xform
#echo $B0_xform
if [ "$EP_xform" != "$B0_xform" ] ; then
    echo "Grids and orientations of EPI and B0map do no match."
#    ! (3dinfo $inputfile | grep "Data Axes Tilt" | grep "Oblique") &> /dev/null ; EP_oblique=$?
#    ! (3dinfo $rpsfile   | grep "Data Axes Tilt" | grep "Oblique") &> /dev/null ; B0_oblique=$?
    EP_oblique=`@isOblique $inputfile`
    B0_oblique=`@isOblique $rpsfile`
    
    # --- AFNI regrid for non-obliques ---
    if [ $EP_oblique -eq 0 -a $B0_oblique -eq 0 ] ; then
        echo "Both EPI and B0map are NOT oblique. Regridding B0map with AFNI 3Dresample."
	    rm -f ${outfroot}_rpsmap_regrid.nii ${outfroot}_rpsmap_mask_regrid.nii  
	    3dresample -inset $rpsfile  -master $inputfile -prefix ${outfroot}_rpsmap_regrid.nii # -rmode Li ??
	    3dresample -inset $maskfile -master $inputfile -prefix ${outfroot}_rpsmap_mask_regrid.nii  
	    B0MAP_FILE=${outfroot}_rpsmap_regrid.nii
	    MASK_FILE=${outfroot}_rpsmap_mask_regrid.nii

    # --- ITK regrid for obliques ---
    else
	    echo "At least one of EPI and B0map are oblique. Regridding B0map with ITK regridImage."
	    NREPS=`fslval $inputfile dim4`
	    if [ $NREPS -gt 1 ] ; then				# ITK regrid only works on 3D target, not 4D
		    nifti_vol0=${outfroot}_epivol0.nii
		    rm -f $nifti_vol0
		    3dbucket -prefix $nifti_vol0 ${inputfile}\[0\] &> /dev/null # this DOES work for obliques
	    else
		    nifti_vol0=$inputfile
	    fi
	    rm -f ${outfroot}_rpsmap_regrid.nii ${outfroot}_rpsmap_mask_regrid.nii  
   	    ${EXECDIR}regridImage -d $rpsfile  -r $nifti_vol0 -p ${outfroot}_rpsmap_regrid.nii      2>/dev/null
  	    tmpdir=`dirname $rpsfile`   # result will be where $rpsfile is
	    B0MAP_FILE=${tmpdir}/${outfroot}_rpsmap_regrid.nii
 	    ${EXECDIR}regridImage -d $maskfile -r $nifti_vol0 -p ${outfroot}_rpsmap_mask_regrid.nii 2>/dev/null
  	    tmpdir=`dirname $maskfile`  
	    MASK_FILE=${tmpdir}/${outfroot}_rpsmap_mask_regrid.nii
    fi
# -- no regrid ---
else
	echo "Grids and orientations of EPI and B0map match. No regridding needed."
	B0MAP_FILE=$rpsfile
	MASK_FILE=$maskfile 
fi

# --- check that shims from B0map acq match EPI acq ---
#b0shims=( `cat b0map_copy.shims` )
#epshims=( `cat ${outfroot}_shims.txt` )
#b0shims="${b0shims[0]} ${b0shims[1]} ${b0shims[2]}" # just compare X/Y/Z vals, cuz other vals are unreliable
#epshims="${epshims[0]} ${epshims[1]} ${epshims[2]}"
#if [ "$epshims" != "$b0shims" ]; then
#	echo "WARNING: EPI images were not acquired with the same shim settings as the B0map."
#	echo "  B0map shim currents:"
#	cat b0map_copy.shims
#	echo "  EPI shim currents:"
#	cat epi.shims
#	exit 1	
#fi

# --- Distortion correct EPIs with FSL---
#cmd="fugue -i $EPIFILE --loadfmap=radmap --mask=$MASK_FILE --unwarpdir=$UNWARP_DIR --dwell=$ESP_COR --poly=4 --unmaskshift --saveshift=shiftmap -u epi_dico" 
#cmd="fugue -i $EPIFILE --loadfmap=radmap --mask=$MASK_FILE --unwarpdir=$UNWARP_DIR --dwell=$ESP_COR --fourier=4 --unmaskshift --saveshift=shiftmap -u epi_dico" 
#cmd="fugue -i $EPIFILE --loadfmap=radmap --mask=$MASK_FILE --unwarpdir=$UNWARP_DIR --dwell=$ESP_COR --fourier=2 --unmaskshift --saveshift=shiftmap -u epi_dico" 
#cmd="fugue -i $EPIFILE --loadfmap=radmap --mask=$MASK_FILE --unwarpdir=$UNWARP_DIR --dwell=$ESP_COR --smooth3=2 --unmaskshift --saveshift=shiftmap -u epi_dico" 
#cmd="fugue -i $inputfile --loadfmap=$B0MAP_FILE --mask=$MASK_FILE --unwarpdir=$UNWARP_DIR --dwell=$ESP_COR --smooth3=$do_smooth --noextend --unmaskshift --saveshift=${outfroot}_shiftmap -u ${outfroot}_dico" 
if [ $extendshift -eq 1 ]; then
    cmd="fugue -i $inputfile --loadfmap=$B0MAP_FILE --mask=$MASK_FILE --unwarpdir=$UNWARP_DIR --dwell=$ESP_COR --smooth3=$do_smooth --unmaskshift --saveshift=${outfroot}_shiftmap -u ${outfroot}_dico" 
else
    cmd="fugue -i $inputfile --loadfmap=$B0MAP_FILE --mask=$MASK_FILE --unwarpdir=$UNWARP_DIR --dwell=$ESP_COR --smooth3=$do_smooth --noextend --unmaskshift --saveshift=${outfroot}_shiftmap -u ${outfroot}_dico" 
fi
echo "-----------------------------------------------"
echo "Running fugue command:"
echo $cmd
eval $cmd
echo ""

# --- Make our own calculation of the shiftmap (should match FSL's) ---
#rm -f shiftmap2.nii
#fslmaths $B0MAP_FILE -mul $ESP_COR -mul $NP  shiftmap2 -odt float

# --- remove intermediate files ---
if [ $keep_files -eq 0 ]; then
    rm -f ${outfroot}.log
    imrm ${outfroot}_rpsmap_regrid ${outfroot}_rpsmap_mask_regrid
    imrm ${outfroot}_magmap_masked ${outfroot}_magmap_coreg ${outfroot}_rpsmap_coreg ${outfroot}_rpsmap_mask_coreg 
    rm -f ${outfroot}.mat
#    imrm $nifti_vol0 
fi

echo "Done."
exit 0

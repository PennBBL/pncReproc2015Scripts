#!/bin/bash
# ---------------------------------------------------------------
# task_coregister_normalize.sh
#
# Coregisters functional data to T1 and normalizes contrasts from FEAT to standard space using an already-computed ANTs warp
#
# Created: Ted Satterthwaite 
# 	    03/2015

# Contact: sattertt@upennn.edu 
#
#
# ---------------------------------------------------------------

#USAGE ---------------------------------------------------------------
Usage() {
    echo ""
    echo "Usage: `basename $0` [options-- see required arguments below]" 
    echo ""
    echo "Obligate Input arguments"
    echo "  --subj=<subjid>			: subjid (e.g. BBLID_SCNAID, ID_DATE) that gets appended to output files"
    echo "  --feat=<feat directory>		: feat directory to use.  Will make a /coregistration directory and place registered maps in the /stats subdirectory"
    echo "  --t1brain=<image>			: brain extracted T1 image"
    echo "  --t1seg=<image>			: Hard segmentation of T1 image"
    echo "  --t1seg_vals=<CSF, GM, WM>		: Intensity value in T1 image of CSF, GM, and WM segments"
    echo "  --coreg_method=<method>		: coregistration method; valid options at present are cost functions supported by flirt; default is BBR"
    echo "  --config=<config>			: config file the specifies ants, R scripts directories"
    echo "  --ants_warp=<ants_warp>		: directory where to find ants warp to template space"    
    echo "  --ants_warp_inv=<ants_warp_inv>     : directory where to find ants inverse warp from template space"
    echo "  --ants_affine=<ants_affine>         : directory where to find ants affine to template space"
    echo "  --template=<template image>		: template image"	
    echo "  --config=<config>			: config file the specifies ants, fsl directories"
    echo ""
    echo "   -h		                        : display this help message"
    echo ""
    exit 1
}
# ---------------------------------------------------------------


# ---------------------------------------------------------------
# Functions for argument parsing
# ---------------------------------------------------------------
get_opt1() {
    arg=`echo $1 | sed 's/=.*//'`
    echo $arg
}

get_imarg1() {
    arg=`get_arg1 $1`;
    arg=`$FSLDIR/bin/remove_ext $arg`;
    echo $arg
}

get_arg1() {
    if [ X`echo $1 | grep '='` = X ] ; then
	echo "Option $1 requires an argument" 1>&2
	exit 1
    else
	arg=`echo $1 | sed 's/.*=//'`
	if [ X$arg = X ] ; then
	    echo "Option $1 requires an argument" 1>&2
	    exit 1
	fi
	echo $arg
    fi
}


# ---------------------------------------------------------------
# Make sure have minimal arguments before continuing (6 total)
# ---------------------------------------------------------------
if [ $# -lt 6 ] ; then Usage; exit 0; fi


# ---------------------------------------------------------------
# Set defaults
# ---------------------------------------------------------------

subj=""
feat=""
t1brain=""
t1seg=""
t1seg_vals=""
coreg_method=bbr
ants_wd=""
template=""

# ---------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------

while [ $# -ge 1 ] ; do
    iarg=`get_opt1 $1`;
    case "$iarg"
	in
	--subj)
		subj=$(get_arg1 $1)
		shift;;
	--feat)
		feat=$(get_arg1 $1)
		shift;;
	--t1brain)
		t1brain=$(get_arg1 $1)
		shift;;
	--t1seg)
		t1seg=$(get_imarg1 $1)
		shift;;
        --t1seg_vals)
                t1seg_vals=$(get_imarg1 $1)
                shift;;
	--coreg_method)
                coreg_method=$(get_arg1 $1)
                shift;;
	--config)
		config=$(get_arg1 $1)
		shift;;
	--ants_warp)
		ants_warp=$(get_arg1 $1)
		shift;;
        --ants_warp_inv)
                ants_warp_inv=$(get_arg1 $1)
                shift;;
        --ants_affine)
                ants_affine=$(get_arg1 $1)
                shift;;
	--template)
		template=$(get_arg1 $1)
		shift;;
	-h)
	  	Usage;
		exit 0;;
	*)
		echo "Unrecognised option $1" 1>&2
		exit 1;;
	esac
done

#----------------------------------------------------------------
# Check required input arguments
# ---------------------------------------------------------------

if [ X$subj = X ] ; then
  echo "The compulsory argument --subj to specify subject ID MUST be used"
  exit 1;
fi

if [ X$feat = X ] ; then
  echo "The compulsory argument --feat to specify feat directory MUST be used"
  exit 1;
fi

if [ X$config = X ] ; then
  echo "The compulsory argument --config to specify a configuration file MUST be specified"
  exit 1;
fi

if [ X$t1brain = X ] ; then
  echo "The compulsory argument --t1brain to specify a brain extracted t1 image MUST be specfied"
  exit 1;
else
  t1brain_test=$(imtest $t1brain)
  if [ "$t1brain_test" -eq 0 ]; then
    echo "t1brain image not found!"
    exit 1
  fi
fi


if [ X$t1seg = X ] ; then
  echo "The compulsory argument --t1seg to specify hard segmentation of t1 image MUST be specfied"
  exit 1;
else
  t1seg_test=$(imtest $t1seg)
  if [ "$t1seg_test" -eq 0 ]; then
    echo "t1 seg image not found!"
    exit 1
  fi
fi

if [ X$t1seg_vals = X ] ; then
  echo "The compulsory argument --t1seg_vals to specify intensity vals of t1 segments (GM, WM, CSF) MUST be used"
  exit 1;
fi

if [ ! -e "$ants_warp" ] || [ ! -e "$ants_affine" ]; then
	"at least one ants file is missing!"
	exit 1
fi


if [ X$template = X ] ; then
  echo "The compulsory argument --template to specify template image MUST be specfied"
  exit 1;
else
  template_test=$(imtest $template)
  if [ "$template_test" -eq 0 ]; then
    echo "template image not found!"
    exit 1
  fi
fi


#----------------------------------------------------------------
# Display input arguments
# ---------------------------------------------------------------
echo ""
echo "__________________________________________"
echo "Input arguments are:"
echo "subject id is $subj"
echo "feat directory is $feat"
echo "template is $template"
echo "config file is $config"
echo "t1 brain is $t1brain"
echo "t1seg is $t1seg"
echo "t1 segmentation values are $t1seg_vals"
echo "coreg method is $coreg_method"
echo "__________________________________________"

#----------------------------------------------------------------
# Setup paths-- from config file
# ---------------------------------------------------------------
source $config

echo "ants directory is $ANTSDIR"
#echo "R dir is $RDIR"
echo "R scripts directory is $RSCRIPTSDIR"
echo "FSL directory is $FSLDIR"
echo "AFNI directory is $AFNIDIR"




#define prestats outputs that will be needed later

mask=$(ls $feat/${subj}_mask.nii.gz 2> /dev/null)
if [ ! -e "$mask" ]; then
	example_func_orig=$(ls $feat/example_func.nii.gz)
	mask_orig=$(ls $feat/mask.nii.gz)
	mv $example_func_orig $feat/${subj}_example_func.nii.gz
	mv $mask_orig $feat/${subj}_mask.nii.gz
fi

example_func=$(ls $feat/${subj}_example_func.nii.gz)
mask=$(ls $feat/${subj}_mask.nii.gz)

if [ ! -e "$example_func" ] || [ ! -e "$mask" ]; then
	echo "expected feat images (example_func or mask) not present; exiting"
	exit 1
fi



#----------------------------------------------------------------
# Coregister functional and structural data
# ---------------------------------------------------------------

echo ""
echo "__________________________________________"


#check if output is present
output=$(ls $feat/coregistration/${subj}_ep2struct.mat 2> /dev/null)
if [ -e "$output" ]; then
	echo "coregistration already run and complete"
else
        #make output directory if not already present
        if [ ! -d "$feat/coregistration" ]; then
                echo "making coregistration directory"
                mkdir ${feat}/coregistration
        fi
        coregdir=$(ls -d ${feat}/coregistration)

	#bet the example_func image if not done
	if [ ! -e "$feat/${subj}_example_func_brain.nii.gz" ]; then
		echo "running bet on example_func"
		bet $example_func $feat/${subj}_example_func_brain -f 0.3
	fi
         example_func_brain=$(ls $feat/${subj}_example_func_brain.nii.gz)

        #make wm segments if not done yet
	if [ ! -e "$coregdir/${subj}_t1wm.nii.gz" ]; then
		echo "making WM segment for use in BBR"
	        wmval=$(echo $t1seg_vals | cut -d, -f3)
	        echo "wm val is $wmval"
                fslmaths $t1seg -thr $wmval -uthr $wmval -bin $coregdir/${subj}_t1wm
	fi
	t1wm=$(ls $coregdir/${subj}_t1wm.nii.gz)


	#run flirt
	echo "running coregistration using method $coreg_method"
	echo "in $example_func_brain"
	echo "ref $t1brain"
	echo "out $coregdir/${subj}_ep2struct"
	echo "omat $coregdir/${subj}_ep2struct.mat"
	flirt -in $example_func_brain -ref $t1brain -dof 6 -out $coregdir/${subj}_ep2struct -omat $coregdir/${subj}_ep2struct.mat -cost $coreg_method -wmseg $t1wm -searchrx -180 180 -searchry -180 180 -searchrz -180 180
        convert_xfm -omat $coregdir/${subj}_struct2ep.mat -inverse $coregdir/${subj}_ep2struct.mat

	cp $example_func_brain $coregdir  #copy to coregdir for help viewing subject-space rois
	cp $mask $coregdir
fi

#general coregistration-resultant dependencies for later use
coregdir=$(ls -d $feat/coregistration)
coregmat=$(ls $coregdir/${subj}_ep2struct.mat)
coregmat_inv=$(ls $coregdir/${subj}_struct2ep.mat)
t1wm=$(ls $coregdir/${subj}_t1wm.nii.gz)
example_func_brain=$(ls $feat/${subj}_example_func_brain.nii.gz)
if [ ! -e "$coregmat" ]; then
	echo "coregistration not present as expected-- something went wrong!!"
	exit 1
fi


#----------------------------------------------------------------
# Convert coreg for ants if not done already, define ants arguments
# ---------------------------------------------------------------

echo ""
echo "__________________________________________"


#convert the coregistration to ANTS format
coregtxt=$(ls -d $coregdir/${subj}_ep2struct.txt 2> /dev/null)
if [ ! -e "$coregtxt" ]; then
	echo "converting mat to ants format"
        $C3DDIR/c3d_affine_tool -src $example_func_brain -ref $t1brain $coregmat -fsl2ras -oitk $coregdir/${subj}_ep2struct.txt
        coregtxt=$(ls -d $coregdir/${subj}_ep2struct.txt)
fi


#----------------------------------------------------------------
# Move certain 3d images-- but not 4d timeseries-- to standard space
# ---------------------------------------------------------------

#check if output present
if [ ! -e "${feat}/${subj}_example_func_brain_std.nii.gz" ]; then

	echo "moving cope and varcope images to standard space"
	
	#make output directory if needed
	regDir=$(ls -d $feat/regStd)
	if [ ! -d "regDir" ]; then
		echo "making output regStd directory for cope/varcope images"
		mkdir $feat/regStd
	fi

        regDir=$(ls -d $feat/regStd)
	echo "regStd dir is $regDir"
	
	#get list of copes/varcopes
	copes=$(ls $feat/stats/*cope*.nii.gz)
	echo "copes and varcopes to register are $copes"
	for c in $copes; do 
		copeName=$(basename $c | cut -d. -f1)
		echo "working on cope $copeName"
	        ${ANTSDIR}/antsApplyTransforms -e 0 -d 3 -i $c -o $regDir/${subj}_${copeName}_std.nii.gz  -r $template -t $ants_warp -t $ants_affine -t $coregtxt
	done

	echo "moving example func and brain mask to standard space"
	${ANTSDIR}/antsApplyTransforms -e 0 -d 3 -i $mask -o ${feat}/${subj}_mask_std.nii.gz  -r $template -t $ants_warp -t $ants_affine -t $coregtxt
        ${ANTSDIR}/antsApplyTransforms -e 0 -d 3 -i $example_func_brain -o ${feat}/${subj}_example_func_brain_std.nii.gz  -r $template -t $ants_warp -t $ants_affine -t $coregtxt
else
	echo "example func already in standard space"
fi

exfunc_std=${feat}/${subj}_example_func_brain_std.nii.gz
if [ ! -e "$exfunc_std" ]; then
	echo "example func not present in std space as expected"
	exit 1
fi





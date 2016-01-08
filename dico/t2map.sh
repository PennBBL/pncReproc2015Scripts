#!/bin/bash
# ---------------------------------------------------------------
# t2map.sh
#
# Calculate T2 or T2* map from multi-echo data
# Created: M Elliott 11/2014
# ---------------------------------------------------------------

# --- Perform standard qa_script code ---
source qa_preamble.sh

# --- Parse command line ---
if [ $# -lt 5 ]; then 
    echo "usage: `basename $0` <nifti1> [<nifti2>] deltaTE <maskfile or "0"> <smooth_in_mm> <outfile>" >&2
    exit 1;
fi
infile1=`imglob -extension $1`
inbase=`basename $infile1`
inroot1=`remove_ext $inbase`
# --- Use 2 separate input volumes ---
if [ $# -eq 6 ]; then 
    infile2=$2
    inbase=`basename $infile2`
    inroot2=`remove_ext $inbase`
    shift
else
    infile2="0"
fi
dTE=$2
maskfile=$3
smooth=$4
outfile=$5
outbase=`basename $outfile`
outroot=`remove_ext $outbase`
outdir=`dirname $outfile`

# --- peel off 2 volumes from 4D input ---
if [ $infile2 = "0" ]; then
    infile=$infile1
    inroot=$inroot1
    
    inroot1=${inroot}_vol1
    fslroi $infile ${outdir}/${inroot1} 0 1
    infile1=`imglob -extension ${outdir}/${inroot1}` # got to get full filename for AFNI automask below
    
    inroot2=${inroot}_vol2
    infile2=${outdir}/${inroot2}
    fslroi $infile $infile2 1 1
fi

# --- mask if needed ---
if [ $maskfile = "0" ]; then
    echo "Automasking..." 
    maskfile=${outdir}/${outbase}_mask.nii
    rm -f $maskfile
    3dAutomask -prefix $maskfile $infile1  2>/dev/null
fi

# --- Log linear fit ---
imrm ${outdir}/${inroot1}_log ${outdir}/${inroot2}_log $outfile
fslmaths $infile1 -s $smooth -mas $maskfile -log  ${outdir}/${inroot1}_ln -odt float
fslmaths $infile2 -s $smooth -mas $maskfile -log  ${outdir}/${inroot2}_ln -odt float
fslmaths ${outdir}/${inroot1}_ln -sub ${outdir}/${inroot2}_ln -div $dTE -recip $outfile -odt float

# --- clean up ---
if [ $keep -eq 0 ]; then 
    imrm ${outdir}/${inroot1}_ln ${outdir}/${inroot2}_ln 
    if [ $# -eq 5 ]; then imrm ${outdir}/${inroot}_vol1 ${outdir}/${inroot}_vol2; fi
fi

exit 0


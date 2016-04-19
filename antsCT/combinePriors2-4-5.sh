#!/bin/bash
# ---------------------------------------------------------------
# combinePriors2-4-5.sh
#
# Combine the GM priors from the output of ANTsCT
#
# afgr March 31 2016
# ---------------------------------------------------------------

# Create a function which will return the usage of this script
usage(){
echo
echo "	Usage:"
echo "  This script will combine the GM priors form the output of ANTsCT"
echo "	It will create an output image in the same directory as the ANTsCT output"
echo "	Required input is the path to the ANTsCT directory"
echo "	combinePriors2-4-5.sh -d </Path/To/ANTsCT/Directory/> -o <outputImageName.nii.gz> -p <pathToParcellationMask.nii.gz> -P <parcOutputDir> -t <templateToQAWith.nii.gz> -D <Optinal1DROIValFile.1D>"
echo
exit 2
}

# Read in the input arguments
while getopts "d:o:p:P:t:D:h" OPTION ; do
  case ${OPTION} in
    d)
      antsDirectory=${OPTARG}
      ;;
    o)
      outputImg=${OPTARG}
      ;;
    p)
      parcMask=${OPTARG}
      ;;
    P)
      parcDir=${OPTARG}
      ;;
    t)
      templateImg=${OPTARG}
      ;;
    D)
      roisVals=${OPTARG}
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
    esac
done

# Check to see if any inputs were not provided
if [ $# == 0 ] | [ -z ${antsDirectory} ] | [ -z ${outputImg} ] | [ -z ${templateImg} ] ; then
  usage ; 
fi

# Now check to see if a parcellation was provided
parcCheck=0
if [ ! -z ${parcMask} ] ; then 
  parcCheck=1 
  dateIndex=`date +%y_%m_%d_%H_%M_%S`
  ctParcOutput="${antsDirectory}${parcDir}/antsCT_val.1D"
  gmdParcOutput="${antsDirectory}${parcDir}/antsGMD_val.1D"
  ctParcLog="${antsDirectory}${parcDir}/roiValCmds${dateIndex}.log" ; 
fi

# Now check to see if a parc dir is provided 
if [ ${parcCheck} -eq 1 ] && [ -z ${parcDir} ] ; then 
  echo "Output parcelation directory must be provided as a input for this script"
  echo "Please provide the directory name with the -P flag"
  echo "Example: -P MARS" 
  exit 4; 
fi


# Now figure out the path to the ants directory
slashDot=`echo ${antsDirectory} | rev | cut -c 1`
if [ ! ${slashDot} == "/" ] ; then 
  echo "Path name must end in a '/'"
  echo "Please add this to your path and then resubmit this job"
  exit 3 ; 
fi

# Now check to see that all of the posteriors are there
if [ ! -f ${antsDirectory}BrainSegmentationPosteriors2.nii.gz ] ; then
  echo "Cortical GM Posterior is missing from ${antsDirectory}"
  echo "Please ensure that all Posteroirs are in the ANTs Directory"
  exit 4 ; 
fi
if [ ! -f ${antsDirectory}BrainSegmentationPosteriors4.nii.gz ] ; then
  echo "Subcortical GM Posterior is missing from ${antsDirectory}"
  echo "Please ensure that all Posteroirs are in the ANTs Directory"
  exit 4 ; 
fi
if [ ! -f ${antsDirectory}BrainSegmentationPosteriors5.nii.gz ] ; then
  echo "Brainstem GM Posterior is missing from ${antsDirectory}"
  echo "Please ensure that all Posteroirs are in the ANTs Directory"
  exit 4 ; 
fi

# Now check that a full path is provided for the antsDirectory
antsCheck=`echo ${antsDirectory} | cut -f 1-5 -d /`
if [ ! "${antsCheck}" == "/data/joy/BBL/studies" ] ; then
  echo "A full path must be provided for the ants directory"
  echo "The path must start from root ('/')"
  echo "Here is an example of a full path:"
  echo "/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/100031/20100918x3818/"
  exit 5 ; 
fi

# Now remove any extension to output name
outputImg=`/share/apps/fsl/5.0.8/bin/remove_ext ${antsDirectory}${outputImg}`

# Now add all of the images together
/share/apps/fsl/5.0.8/bin/fslmaths ${antsDirectory}BrainSegmentationPosteriors2.nii.gz -add ${antsDirectory}BrainSegmentationPosteriors4.nii.gz -add ${antsDirectory}BrainSegmentationPosteriors5.nii.gz ${outputImg}

# Now I need to apply the transform to the pnc template using antsApplyTransforms
# We should use the same ants that was used to create the ANTsCT
antsPath="/data/joy/BBL/applications/ants_20151007/bin/"
templateImg="/data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz"
${antsPath}antsApplyTransforms -d 3 -i ${outputImg}.nii.gz -r ${templateImg} -o ${outputImg}SubjectToTemplate.nii.gz -t ${antsDirectory}SubjectToTemplate0GenericAffine.mat -t ${antsDirectory}SubjectToTemplate1Warp.nii.gz
roiCmd="/share/apps/afni/linux_xorg7_64_2014_06_16/3dROIstats"
ccCmd="/share/apps/fsl/5.0.8/bin/fslcc"
maths="/share/apps/fsl/5.0.8/bin/fslmaths"
stats="/share/apps/fsl/5.0.8/bin/fslstats"

# Now if we have a parcellatino lets output a ROI stats on it
if [ ${parcCheck} -eq 1 ] ; then 
  # First lets declare some subject variables
  pfxtab=`echo ${antsDirectory} | rev | cut -f 2-3 -d / | rev | sed s@'/'@'\t'@`
  idVars="subject[0],subject[1]"
  idVars=$(echo ${idVars}|sed s@'^,'@@|sed s@','@'\t'@g)
  pfxSubjFileName=`echo ${pfxtab} | sed s@' '@'_'@`
  ctParcOutput="${antsDirectory}${parcDir}/${pfxSubjFileName}_${parcDir}_antsCT_val.1D"
  gmdParcOutput="${antsDirectory}${parcDir}/${pfxSubjFileName}_${parcDir}_antsGMD_val.1D"


  # Now lets check to see that all of the output exists   
  if [ ! -f ${antsDirectory}CorticalThickness.nii.gz ] ; then 
    echo "CorticlThickness.nii.gz is missing from ${antsDirectory}"
    echo "Please ensure all antsCT outputs exists before running this script"
    exit 4 ; 
  fi
  # Now create the output directory
  if [ ! -d ${antsDirectory}${parcDir}/ ] ; then 
    mkdir ${antsDirectory}${parcDir}/ ; 
  fi

  # These next two if statements are going to be used to control for the 1D output roi value file
  # If no roisVals.1D file is provided I am just going to give a mean value for every intensity range found in 
  # The parcellation file, how ever if a 1D file is provided then I will provdide mean values for only that 
  # presepcified intensity range.
  
  # Now find the total number of ROI's which will be supplied to the 3dROIstats command
  if [ "X${roisVals}" == "X" ] ; then
    intensityRange=`${stats} ${parcMask} -R | cut -f 2 -d ' ' | cut -f 1 -d '.'`
    roiValOutput="-numROI ${intensityRange}" ; 
  else
    roiValOutput="-roisel ${roisVals}" ; 
  fi
   
  # Create the roi commands
  parcCommandCT="${roiCmd} -1DRformat ${roiValOutput} -zerofill NA -mask ${parcMask} ${antsDirectory}CorticalThickness.nii.gz"
  parcCommandGMD="${roiCmd} -1DRformat ${roiValOutput} -zerofill NA -mask ${parcMask} ${outputImg}.nii.gz"
  
  # Now echo them to the log files
  echo ${parcCommandCT} > ${ctParcLog}
  echo ${parcCommandGMD} >> ${ctParcLog}

  # Now create the 1D file
  ${parcCommandCT} > ${ctParcOutput}
  ${parcCommandGMD} > ${gmdParcOutput} 
  
  # Now Change the fields for the cortical thickness output
  idVars=$(echo ${idVars}|sed s@'^,'@@|sed s@','@'\t'@g)
  parVals=$(cat ${ctParcOutput} \
    |sed s@'^name'@"${idVars}"@g \
    |sed s@'^/[^\t]*'@"${pfxtab}"@g)
  rm -f ${ctParcOutput}
  echo "${parVals}" >> ${ctParcOutput} 

  # Now change the fields for the gmd output
  idVars=$(echo ${idVars}|sed s@'^,'@@|sed s@','@'\t'@g)
  parVals=$(cat ${gmdParcOutput} \
    |sed s@'^name'@"${idVars}"@g \
    |sed s@'^/[^\t]*'@"${pfxtab}"@g)
  rm -f ${gmdParcOutput}
  echo "${parVals}" >> ${gmdParcOutput} ;
fi

# Now perform all of the QA steps
# QA will mirror everything performed in the $XCPEDIR norm module
# This includes cross corellation, and coverage
# Lets start with CC
qa_cc=$(${ccCmd} ${antsDirectory}BrainNormalizedToTemplate.nii.gz ${templateImg} | awk '{print $3}')
randDigit1=${RANDOM}
randDigit2=${RANDOM}

# Now create the binary masks for which we will compute missed registration voxels with
${maths} ${antsDirectory}BrainNormalizedToTemplate.nii.gz -bin ${TMPDIR}tmp_${randDigit1}
${maths} ${templateImg} -bin ${TMPDIR}tmp_${randDigit2}

# Now subtract the two masks from each other
${maths} ${TMPDIR}tmp_${randDigit1} -sub ${TMPDIR}tmp_${randDigit2} -thr 0 -bin ${TMPDIR}subj2std_mask_diff
${maths} ${TMPDIR}tmp_${randDigit2} -sub ${TMPDIR}tmp_${randDigit1} -thr 0 -bin ${TMPDIR}std2subj_mask_diff

# Now compute coverage
qa_vol_subj=$(${stats} ${TMPDIR}tmp_${randDigit1} -V | awk '{print $2}')
qa_vol_std=$(${stats} ${TMPDIR}tmp_${randDigit2} -V | awk '{print $2}')
qa_vol_diff=$(${stats} ${TMPDIR}std2subj_mask_diff -V | awk '{print $2}')
qa_cov_obs=$(echo "scale=10; 1 - ${qa_vol_diff} / ${qa_vol_std}" | bc)
qa_cov_max=$(echo "scale=10; ${qa_vol_subj} / ${qa_vol_std}" | bc)
[[ $(echo "scale=10; ${qa_cov_max} > 1"|bc -l) == 1 ]] && qa_cov_max=1
qa_coverage=$(echo "scale=10; ${qa_cov_obs} / ${qa_cov_max}" | bc)

# Now lets echo the output to the quality output file
qualityOutput="${antsDirectory}${pfxSubjFileName}_normQuality.csv"
# Now redeclare the subject variables as comma delimmited
pfxSubjFileName=`echo ${pfxtab} | sed s@' '@','@`
echo "subject[0],subject[1],norm_crosscorr,norm_coverage" > ${qualityOutput}
echo ${pfxSubjFileName,},${qa_cc},${qa_coverage} >> ${qualityOutput}

# Now clean up the tmp files
rm -f ${TMPDIR}tmp_${randDigit1}*  
rm -f ${TMPDIR}tmp_${randDigit2}*  
rm -f ${TMPDIR}subj2std_mask_diff* 
rm -f ${TMPDIR}std2subj_mask_diff*


echo "All Done"
exit 0




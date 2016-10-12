#!/bin/bash
# ---------------------------------------------------------------
# antsCTPostProcAndGMD.sh
#
# Perform variaous file manipulation on images from the output
# of the ANTsCT pipeline, and then calculate GMD on the Skull Stripped
# and bias field corrected images.
#
# afgr August 9 2016
# ---------------------------------------------------------------

# Create a function which will return the usage of this script
usage(){
echo
echo "	Usage:"
echo "  This script will perform variaous file manipulation and calculation"
echo "  of GMD on images that have been run through ANTsCT"
echo "	Required input is the path to the ANTsCT directory"
echo "	antsCTPostProcAndGMD.sh -d </Path/To/ANTsCT/Directory/> -o <outputImageName.nii.gz> -p <pathToParcellationMask.nii.gz> -P <parcOutputDir> -t <templateToQAWith.nii.gz> -s <applyInverseTransformToParcel>"
echo
exit 2
}

# Read in the input arguments
while getopts "d:o:p:P:t:s:h" OPTION ; do
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
    s)
      applyInverse=${OPTARG}
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
    esac
done

## Now lets declare some static variables and check to 
## see we have all of our dependents 
depCheck=0
AP=${ANTSPATH}/
if [ "X${AP}" == "X" ] ; then
  echo "ANTSPATH variable not defined please add ANTSPATH to your .bash_profile"
  depcheck=1 ; 
fi
FSP=${FSL_BIN}/
if [ "X${FSP}" == "X" ] ; then
  echo "FSL_BIN variable not defined please add FSLDIR to your .bash_profile"
  depcheck=1 ; 
fi
AFP=`which 3dROIstats | xargs dirname`
if [ "X${AFP}" == "X" ] ; then
  echo "AFNI_PATH variable not defined please add AFNI_PATH to your .bash_profile"
  depcheck=1 ; 
fi
AFP=${AFP}/

# Now exit with the usage statement if we are missing a dependency
if [ ${depCheck} -eq 1 ] ; then
  usage ;
fi

# Check to see if any inputs were not provided
if [ $# == 0 ] | [ -z ${antsDirectory} ] | [ -z ${outputImg} ] | [ -z ${templateImg} ] ; then
  usage ; 
fi

# Now check to see if a parcellation was provided
parcCheck=0
if [ ! -z ${parcMask} ] ; then 
  parcCheck=1 
  dateIndex=`date +%y_%m_%d_%H_%M_%S`
  ctParcLog="${antsDirectory}${parcDir}/roiValCmds${dateIndex}.log" ; 
fi

# Now check to see if a parc dir is provided 
if [ ${parcCheck} -eq 1 ] && [ -z ${parcDir} ] ; then 
  echo "Output parcelation directory must be provided as a input for this script"
  echo "Please provide the directory name with the -P flag"
  echo "Example: -P JLF" 
  exit 4; 
fi

# Now figure out the path to the ants directory
slashDot=`echo ${antsDirectory} | rev | cut -c 1`
if [ ! ${slashDot} == "/" ] ; then 
  echo "Path name must end in a '/'"
  echo "Please add this to your path and then resubmit this job"
  exit 3 ; 
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

## Now lets calculate GMD in the native image
# First thing we have to do is normalize the image
${AP}ImageMath 3 ${outputImg}_norm.nii.gz Normalize ${antsDirectory}ExtractedBrain0N4.nii.gz

# Now run 3 iterations of atropos
for i in 1 2 3 ; do
  if [ ${i} -eq 1 ] ; then
    ${AP}Atropos -d 3 -a ${outputImg}_norm.nii.gz -i KMeans[3] \
                 -c [ 5,0] -m [ 0,1x1x1] -x ${antsDirectory}BrainExtractionMask.nii.gz \
                 -o [ ${outputImg}_seg.nii.gz, ${outputImg}_prob%02d.nii.gz]
  else
    ${AP}Atropos -d 3 -a ${outputImg}_norm.nii.gz \
                 -i PriorProbabilitImages[ 3,${outputImg}_prob%02d.nii.gz,0.0] \
                 -k Gaussian -p Socrates[1] --use-partial-volume-likelihoods 0 \
                 -c [ 12, 0.00001] \
                 -x ${antsDirectory}BrainExtractionMask.nii.gz \
                 -m [ 0,1x1x1] \
                 -o [ ${outputImg}_seg.nii.gz, ${outputImg}_prob%02d.nii.gz] ; 
  fi ; 
done 

## Now I need to warp our output to the template
${AP}antsApplyTransforms -d 3 -i ${outputImg}_prob02.nii.gz \
                         -r ${templateImg} -o ${outputImg}_prob02SubjToTemp.nii.gz \
                         -t ${antsDirectory}SubjectToTemplate0GenericAffine.mat \
                         -t ${antsDirectory}SubjectToTemplate1Warp.nii.gz

## Now I need to warp the JLF labels into template space using the same steps as above
${AP}antsApplyTransforms -d 3 -i ${parcMask} \
                         -r ${templateImg} -o ${antsDirectory}${parcDir}_subjectToTemplate.nii.gz \
                         -t ${antsDirectory}SubjectToTemplate0GenericAffine.mat \
                         -t ${antsDirectory}SubjectToTemplate1Warp.nii.gz

## Now create the jacobian mask so I can create a 
## volume modulated density mask
${AP}CreateJacobianDeterminantImage 3 ${antsDirectory}SubjectToTemplate1Warp.nii.gz \
                                    ${antsDirectory}subjectToTemplateJacobian.nii.gz \
                                    0 1

# And now create the volume modulated GMD scores by multiplying
# the jacobian image to the GM priors
${AP}ImageMath 3 ${outputImg}_prob02SubjToTempVolumeModulated.nii.gz m ${outputImg}_prob02SubjToTemp.nii.gz ${antsDirectory}subjectToTemplateJacobian.nii.gz
     
# Now convert the data type so it is compatible with afni
${FSP}fslmaths ${antsDirectory}${parcDir}_subjectToTemplate.nii.gz -mul 1 ${antsDirectory}${parcDir}_subjectToTemplate.nii.gz -odt short

# Now create our final gmd Image by multiplyting the GMD parcellation by
# the Atropos GM segmented mask
${FSP}fslmaths ${outputImg}_seg.nii.gz -thr 2 -uthr 2 -bin ${outputImg}_seg_GmMask.nii.gz
${FSP}fslmaths ${outputImg}_prob02.nii.gz -mul ${outputImg}_seg_GmMask.nii.gz ${outputImg}_prob02_IsolatedGM.nii.gz

## Now compute the GMD using the provided parcellation
if [ ${parcCheck} -eq 1 ] ; then
  if [ ${applyInverse} -eq 1 ] ; then
    echo "Now moving Parcellation mask into Subject Space"
    ${AP}antsApplyTransforms -d 3 -e 3 -i ${parcMask} -o ${antsDirectory}${parcDir}ToSubject.nii.gz -r ${antsDirectory}ExtractedBrain0N4.nii.gz -t ${antsDirectory}TemplateToSubject1GenericAffine.mat -t ${antsDirectory}TemplateToSubject0Warp.nii.gz -n NearestNeighbor 
    parcMask=${antsDirectory}${parcDir}ToSubject.nii.gz ; 
  fi
  
  # Make the output parcellation directory
  mkdir -p ${antsDirectory}${parcDir}
  
  # Now declare some outputs and subject variables
  pfxtab=`echo ${antsDirectory} | rev | cut -f 2-3 -d / | rev | sed s@'/'@'\t'@`
  idVars="subject[0],subject[1]"
  idVars=$(echo ${idVars}|sed s@'^,'@@|sed s@','@'\t'@g)
  pfxSubjFileName=`echo ${pfxtab} | sed s@' '@'_'@`
  
  # Now prep the 3dROIstats commands
  intensityRange=`${FSP}fslstats ${parcMask} -R | cut -f 2 -d ' ' | cut -f 1 -d '.'`
  roiValOutput="-numROI ${intensityRange}"
  ctParcOutput="${antsDirectory}${parcDir}/${pfxSubjFileName}_${parcDir}_antsCT_val.1D"
  gmdParcOutput="${antsDirectory}${parcDir}/${pfxSubjFileName}_${parcDir}_antsGMD_val.1D"
  gmdIsolParcOutput="${antsDirectory}${parcDir}/${pfxSubjFileName}_${parcDir}_antsGMDIsol_val.1D"
  parcCommandCT="${AFP}/3dROIstats -1DRformat ${roiValOutput} -zerofill NA -mask ${parcMask} ${antsDirectory}CorticalThickness.nii.gz"
  parcCommandGMD="${AFP}/3dROIstats -1DRformat ${roiValOutput} -zerofill NA -mask ${parcMask} ${outputImg}_prob02.nii.gz"
  parcCommandGMDIsol="${AFP}/3dROIstats -1DRformat ${roiValOutput} -zerofill NA -mask ${parcMask} ${outputImg}_prob02_IsolatedGM.nii.gz"

  # Now run and log the commands
  ${parcCommandCT} > ${ctParcOutput}
  ${parcCommandGMD} > ${gmdParcOutput} 
  ${parcCommandGMDIsol} > ${gmdIsolParcOutput}

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
  echo "${parVals}" >> ${gmdParcOutput}


  # Now change the fields for the gmd output
  idVars=$(echo ${idVars}|sed s@'^,'@@|sed s@','@'\t'@g)
  parVals=$(cat ${gmdIsolParcOutput} \
  |sed s@'^name'@"${idVars}"@g \
  |sed s@'^/[^\t]*'@"${pfxtab}"@g)
  rm -f ${gmdIsolParcOutput}
  echo "${parVals}" >> ${gmdIsolParcOutput}

  # Now repeat these steps for the volume modulated GMD output
  gmdParcOutputVolMod="${antsDirectory}${parcDir}/${pfxSubjFileName}_${parcDir}_antsGMD_VolMod_val.1D"
  parcCommandGMDVolMod="${AFP}/3dROIstats -1DRformat ${roiValOutput} -zerofill NA -mask ${antsDirectory}${parcDir}_subjectToTemplate.nii.gz ${outputImg}_prob02SubjToTempVolumeModulated.nii.gz"

  # Now run and log the commands
  ${parcCommandGMDVolMod} > ${gmdParcOutputVolMod}

  # Now change the appropraiet fields
  idVars=$(echo ${idVars}|sed s@'^,'@@|sed s@','@'\t'@g)
  parVals=$(cat ${gmdParcOutputVolMod} \
    |sed s@'^name'@"${idVars}"@g \
    |sed s@'^/[^\t]*'@"${pfxtab}"@g)
  rm -f ${gmdParcOutputVolMod}
  echo "${parVals}" >> ${gmdParcOutputVolMod}
fi

# Now perform all of the QA steps
# QA will mirror everything performed in the $XCPEDIR norm module
# This includes cross corellation, and coverage
# Lets start with CC
qa_cc=$(${FSP}fslcc ${antsDirectory}BrainNormalizedToTemplate.nii.gz ${templateImg} | awk '{print $3}')
randDigit1=${RANDOM}
randDigit2=${RANDOM}

# Now create the binary masks for which we will compute missed registration voxels with
${FSP}fslmaths ${antsDirectory}BrainNormalizedToTemplate.nii.gz -bin ${TMPDIR}tmp_${randDigit1}
${FSP}fslmaths ${templateImg} -bin ${TMPDIR}tmp_${randDigit2}

# Now subtract the two masks from each other
${FSP}fslmaths ${TMPDIR}tmp_${randDigit1} -sub ${TMPDIR}tmp_${randDigit2} -thr 0 -bin ${TMPDIR}subj2std_mask_diff
${FSP}fslmaths ${TMPDIR}tmp_${randDigit2} -sub ${TMPDIR}tmp_${randDigit1} -thr 0 -bin ${TMPDIR}std2subj_mask_diff

# Now compute coverage
qa_vol_subj=$(${FSP}fslstats ${TMPDIR}tmp_${randDigit1} -V | awk '{print $2}')
qa_vol_std=$(${FSP}fslstats ${TMPDIR}tmp_${randDigit2} -V | awk '{print $2}')
qa_vol_diff=$(${FSP}fslstats ${TMPDIR}std2subj_mask_diff -V | awk '{print $2}')
qa_cov_obs=$(echo "scale=10; 1 - ${qa_vol_diff} / ${qa_vol_std}" | bc)
qa_cov_max=$(echo "scale=10; ${qa_vol_subj} / ${qa_vol_std}" | bc)
[[ $(echo "scale=10; ${qa_cov_max} > 1"|bc -l) == 1 ]] && qa_cov_max=1
qa_coverage=$(echo "scale=10; ${qa_cov_obs} / ${qa_cov_max}" | bc)

##### TMP QA GMD FIX #######
###
### 
### This should be rm'ed afgr is including this just so I can get work done quicker

## Now resample so we have a regressor for our CBF data
${AP}antsApplyTransforms -d 3 -i ${outputImg}_prob02SubjToTemp.nii.gz -r /data/joy/BBL/studies/pnc/template/priors/prior_grey_thr01_2mm.nii.gz -o ${outputImg}_prob02SubjToTemp2mm.nii.gz
${AP}antsApplyTransforms -d 3 -i ${antsDirectory}CorticalThicknessNormalizedToTemplate.nii.gz -r /data/joy/BBL/studies/pnc/template/priors/prior_grey_thr01_2mm.nii.gz -o ${antsDirectory}CorticalThicknessNormalizedToTemplate2mm.nii.gz
# Now compute average GMD over GM compartment
gmValue=`${AFP}3dROIstats -mask /data/joy/BBL/studies/pnc/template/priors/prior_grey_thr01_2mm.nii.gz ${outputImg}_prob02SubjToTemp2mm.nii.gz | cut -f 3 | tail -n 1`


# Now lets echo the output to the quality output file
qualityOutput="${antsDirectory}${pfxSubjFileName}_normQuality.csv"
# Now redeclare the subject variables as comma delimmited
pfxSubjFileName=`echo ${pfxtab} | sed s@' '@','@`
echo "subject[0],subject[1],norm_crosscorr,norm_coverage,mean_gmd_val" > ${qualityOutput}
echo ${pfxSubjFileName,},${qa_cc},${qa_coverage},${gmValue} >> ${qualityOutput}

# Now clean up the tmp files
rm -f ${TMPDIR}tmp_${randDigit1}*  
rm -f ${TMPDIR}tmp_${randDigit2}*  
rm -f ${TMPDIR}subj2std_mask_diff* 
rm -f ${TMPDIR}std2subj_mask_diff*





## Further down here I will need to modify all of the names in the directory so I can append 

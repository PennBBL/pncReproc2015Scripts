#!/bin/bash

# I need to create a mask of the images that have been flagged, provided by an input csv of bblid and datexscanid
inputCsv=${1}
outputImageName=${2}

# Now declare some statics
pcaslDir="/data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/"
outputDir="/data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/"
loopLength=`more ${inputCsv} | wc -l`

# Now run through a loop and binarize each image, store it temporarily in the output dir and then combine them all into one
for i in `seq 2 ${loopLength}` ; do 
  bblid=`sed -n "${i}p" ${inputCsv} | cut -f 1 -d ,`
  scanid=`sed -n "${i}p" ${inputCsv} | cut -f 2 -d ,`
  echo "${bblid}_${scanid}"
  imageToBinarize=`ls ${pcaslDir}${bblid}/${scanid}/norm/${bblid}_${scanid}_maskStd.nii.gz`
  outputImageTmp="${outputDir}/temp-foo-bar_${bblid}_${scanid}.nii.gz"
  fslmaths ${imageToBinarize} -bin ${outputImageTmp} ; 
done

fslmerge -t ${outputImageName} `ls ${outputDir}/temp-foo-bar*nii.gz`
ls ${outputDir}temp-foo-bar*nii.gz > ${outputDir}/subjectOrder.txt
rm -f ${outputDir}/temp-foo-bar*nii.gz

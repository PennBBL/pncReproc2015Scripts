#!/bin/bash

# This script will be used to find ht eunion between JLF segmentations and ANTsCT GM segmentations.
# The required inputs will be our JLF segmentation and the ANTsCT segmentation image.
# It will be used to produce more correct JLF segmentation values. 

## Declare the usage function
usage(){
echo
echo
echo
echo "${0} <jlfSegmentation.nii.gz> <ANTsCTSegmentation.nii.gz> <outputImageName> <OPTIONAL:OutputVolumeDifferences>"
echo "jlfSegmentation.nii.gz is the output of the JLF pipeline as detailed here:"
echo "https://github.com/PennBBL/pncReproc2015Scripts/wiki/PNC-T1-Image-segmentation-with-multi-atlas-labeling"
echo
echo "ANTsCTSegmentation.nii.gz is the hard label output from the ANTsCT segmentation as detailed here:"
echo "https://github.com/PennBBL/pncReproc2015Scripts/wiki/PNC-T1-Processing-with-ANTs#cortical-thickness"
echo 
echo "ouputImageName : is the name of the output image"
echo
echo "OPTIONAL: OUtputVolumeDifferences is a text file which will hold the two totoal volume values for the"
echo "pre and post JLF GM masking volumes"
echo
echo "Should any issues arise trying to use this script eamil: adrose@mail.med.upenn.edu"
exit 1
}

## First declare all static variables
createBinMask="/data/joy/BBL/applications/xcpEngine/utils/val2mask.R"
valsToBin="2:6"
csfValsToBin="4,11,46,51,52"
tmpDir="/tmp/jlfIsol${RANDOM}"
workingDir=`pwd`
jlfParcel=${1}
antsCTSeg=${2}
outputImage=${3}
# Now make sure we have all of our statics
if [ ! -f ${jlfParcel} ] ; then
  echo "**"
  echo "**"
  echo "No JLF Parcel present"
  echo "**"
  echo "**"
  usage;
fi

if [ ! -f ${antsCTSeg} ] ; then 
  echo "**"
  echo "**"
  echo "No ANTsCT Parcel present"
  echo "**"
  echo "**"
  usage;
fi 

if [ "X${outputImage}" == "X" ] ; then
  echo "**"
  echo "**"
  echo "No outputImage Name provided!"
  echo "**"
  echo "**"
  usage;
fi  

# Create the tmpdir 
mkdir ${tmpDir}
cd ${tmpDir}

# Now create the mask image
${createBinMask} -i ${antsCTSeg} -v ${valsToBin} -o ${tmpDir}/thresholdedImage.nii.gz 
${createBinMask} -i ${jlfParcel} -v ${csfValsToBin} -o ${tmpDir}/binMaskCSF.nii.gz
${createBinMask} -i ${jlfParcel} -v "61,62" -o ${tmpDir}/binMaskVD.nii.gz

# Now fix the csf image
3dmask_tool -input ${tmpDir}/binMaskCSF.nii.gz -prefix ${tmpDir}/binMaskCSF_dil.nii.gz -dilate_input 2 -quiet

# Now multiply our values together 
fslmaths ${tmpDir}/thresholdedImage.nii.gz -add ${tmpDir}/binMaskCSF_dil.nii.gz -add ${tmpDir}/binMaskVD.nii.gz -bin ${tmpDir}/thresholdedImage.nii.gz
fslmaths ${tmpDir}/thresholdedImage.nii.gz -mul ${jlfParcel} ${tmpDir}/maskedJLFParcel

# Now we need to check to see if we have the optional input
if [ ! "X${4}" == "X" ] ; then 
  # Now grab our volume values
  oVolume=`fslstats ${jlfParcel} -V | cut -f 2 -d ' '`
  nVolume=`fslstats ${tmpDir}/maskedJLFParcel -V | cut -f 2 -d ' '`

  # Now prepare our output
  outputValues="${oVolume},${nVolume}"
  
  # Now send it to the file
  echo ${outputValues} >> ${4} ; 
fi


# Now move our output to the output name provided
mv ${tmpDir}/maskedJLFParcel.nii.gz ${3}

# Now cd back to the original WD and rm the tmp dir
cd ${workingDir}
rm -rf ${tmpDir}

# Now exit
exit 0

#!/bin/bash
# This script is going to be used as a wrapper for several scripts
# The output of this script is going to be a wm mask with lobular segmentations
# from the output of JLF... This script is JLF SPECIFIC!
# The required input for this script is the JLF segmentation
# The usage of this script is as follows:
#	createFistanceMetricsMask.sh <yourJLFSegmentation.nii.gz> <yourOutputSegmentation.nii.gz>

# There are several dependencies for this script they include:
#	1.) JLF segmentation
#	2.) /data/jet/grosspeople/Volumetric/SIEMENS/pipedream2014/antsMalf/scripts/oasisLabelsToLobar.sh
#		2.1) ANTS ImageMaths
#	3.) ANTsR & R... obviously
#		3.1) R script to decide upon lobe placement
#	4.) FSL
#	5.) Ants ImageMath

# Declare a usage statement and any other functions
Usage(){
  echo ""; echo ""; echo ""
  echo "Usage: `basename $0` <yourJLFSegmentation.nii.gz> <yourOutPutSegmentation.nii.gz>"
  echo ""
  echo "**This script will only accept 2 input**"
  exit 2
}

function clearLastLine() {
        tput cuu 1 && tput el
}

# Lets check to see if an input was provided
if [[ $# -gt 2 ]] ; then
  Usage ; 
fi
imageToSegment=$1
[[ -z ${imageToSegment} ]] && Usage
outputImage=$2
[[ -z ${outputImage} ]] && Usage


# First lets declare any statics 
lobarScript="/data/jet/grosspeople/Volumetric/SIEMENS/pipedream2014/antsMalf/scripts/oasisLabelsToLobar.sh"
randomValue=${RANDOM}
tmpDirectory="/tmp/tmpWmSeg${RANDOM}/"
lobeValuesRight="/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/wmSegmentation/lobeValuesRight.csv"
lobeValuesLeft="/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/wmSegmentation/lobeValuesLeft.csv"
lobularImage="${tmpDirectory}lobarImage${randomValue}.nii.gz"
findMinimum="/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/wmSegmentation/findMaskMinimum.R"

echo "tmp Directory is ${tmpDirectory}"

# Create our directory to work out of
mkdir -p ${tmpDirectory}
mkdir -p ${tmpDirectory}right/
mkdir -p ${tmpDirectory}left/

# Now create our lobar mask's... all of them 
echo "Now createing lobular image"
${lobarScript} ${imageToSegment} ${lobularImage}

# Now go through and isolate each of our lobes of interest
# we are going to start with the right hemisphere
for i in `seq 1 7` ; do 
  rightValue=`sed -n -e "${i}p" ${lobeValuesRight} | cut -f 1 -d ,`
  rightName=`sed -n -e "${i}p" ${lobeValuesRight} | cut -f 2 -d ,`
  echo "Now Isolating ${rightName}"
  fslmaths ${lobularImage} -thr ${rightValue} -uthr ${rightValue} -bin ${tmpDirectory}/right/${rightName}.nii.gz ; 
done

# Now do the left hemisphere
for i in `seq 1 7` ; do
  leftValue=`sed -n -e "${i}p" ${lobeValuesLeft} | cut -f 1 -d ,`
  leftName=`sed -n -e "${i}p" ${lobeValuesLeft} | cut -f 2 -d ,`
  echo "Now Isolating ${leftName}"
  fslmaths ${lobularImage} -thr ${leftValue} -uthr ${leftValue} -bin ${tmpDirectory}/left/${leftName}.nii.gz ; 
done

# Now we need to create our distance metrics per lobe and then threshold them to limit them to our wm mask
# Lets again start with the right 
echo "Now computing distance from each lobe for the right hemisphere"
fslMergeCommand="fslmerge -t ${tmpDirectory}/right/concatDistanceImage.nii.gz"
for i in `seq 1 6` ; do 
  rightName=`sed -n -e "${i}p" ${lobeValuesRight} | cut -f 2 -d ,`
  ImageMath 3 ${tmpDirectory}/right/${rightName}-Distance.nii.gz D ${tmpDirectory}/right/${rightName}.nii.gz
  fslmaths ${tmpDirectory}/right/${rightName}-Distance.nii.gz -mul ${tmpDirectory}/right/Right_Cerebral_Lobe.nii.gz ${tmpDirectory}/right/${rightName}-Distance.nii.gz 
  fslMergeCommand="${fslMergeCommand} ${tmpDirectory}/right/${rightName}-Distance.nii.gz"
  #clearLastLine
  echo -ne "${i} of 6\033[0K\r"; 
done
# Now lets make a 4-d image with these
echo "Now merging right hemisphere images"
${fslMergeCommand}
# Now assign a lobe to each of these
R --slave -f ${findMinimum} ${tmpDirectory}/right/concatDistanceImage.nii.gz ${tmpDirectory}/right/Right_Cerebral_Lobe.nii.gz

## Now repeat for the left lobe 
echo "Now computing distance from each lobe for the left hemisphere"
fslMergeCommand="fslmerge -t ${tmpDirectory}/left/concatDistanceImage.nii.gz"
for i in `seq 1 6` ; do 
  leftName=`sed -n -e "${i}p" ${lobeValuesLeft} | cut -f 2 -d ,`
  ImageMath 3 ${tmpDirectory}/left/${leftName}-Distance.nii.gz D ${tmpDirectory}/left/${leftName}.nii.gz
  fslmaths ${tmpDirectory}/left/${leftName}-Distance.nii.gz -mul ${tmpDirectory}/left/Left_Cerebral_Lobe.nii.gz ${tmpDirectory}/left/${leftName}-Distance.nii.gz 
  fslMergeCommand="${fslMergeCommand} ${tmpDirectory}/left/${leftName}-Distance.nii.gz"
  #clearLastLine
  echo -ne "${i} of 6\033[0K\r"; 
done
  
# Now merging the left hemisphere images
${fslMergeCommand}

# Now create a left lobe WM inflation mask
fslmaths ${tmpDirectory}/left/Left_Cerebral_Lobe.nii.gz -add 6 ${tmpDirectory}/left/Left_Cerebral_Lobe_Inflation.nii.gz

# Now assign a lobe to each of these
R --slave -f ${findMinimum} ${tmpDirectory}/left/concatDistanceImage.nii.gz ${tmpDirectory}/left/Left_Cerebral_Lobe.nii.gz

# Now combine our masks into the output request
fslmaths ${tmpDirectory}/left/Left_Cerebral_Lobe_WithLobeValues.nii.gz -add ${tmpDirectory}/left/Left_Cerebral_Lobe_Inflation.nii.gz -add ${tmpDirectory}/right/Right_Cerebral_Lobe_WithLobeValues.nii.gz ${outputImage}

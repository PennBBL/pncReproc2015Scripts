#!/bin/bash
# AFGR Aug 17 2016
# This script is going to be used to prepare a csv for the images that need to be QA'ed for the JLF output
# It is going to load the proper images to read for each of the T1 modalities
# It will then prmpt the user as to if the image can be used or not 
# Also of quick note this script will only work for users arosen & agarza on chead due to the rushed nature of the produciton of this script =D

# First thing is lets load the static variables
startnum=0
appendOut1=`whoami`
appendOut2=`date +%y_%m_%d_%H_%M_%S`
outfiledir="/data/joy/BBL/projects/pncReproc2015/n2416QAT1/manualQAOutput/"
outfile="${outfiledir}/${appendOut1}outfile${appendOut2}.csv"
indexFile="${outfiledir}/.${appendOut1}_indexfile.txt"
antsCTDir="/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/"
jlfDir="/data/joy/BBL/studies/pnc/processedData/structural/jlf/"

# Now lets prep all of the images 
infileBase="/data/joy/BBL/projects/pncReproc2015/n2416QAT1/flaggingBasedonSD/"
inFileAll="${infileBase}allImageQA${appendOut1}.csv"
inFileGMD="${infileBase}gmdImageQA.csv"
inFileCT="${infileBase}ctImageQA.csv"
inFileANTS="${infileBase}antsImageQA.csv"
inFileJLF="${infileBase}jlfImageQA.csv"

# Now prepare everything we will need to start the QA
if [ ! -d "${outfiledir}" ] ; then
  mkdir ${outfiledir} ; 
fi
if [ ! -f ${indexFile} ] ; then
  echo "${startnum}" > ${indexFile} ; 
fi

echo "number, bblid, scanid, GMD, CT, BM, ANTS, JLF, Useable, Notes" >> ${outfile}

# Now loop through each bblid and scanid and load the corresponding images
for i in `tail -n +${startnum} ${inFileAll}` ; do
  bblid=`echo ${i} | cut -f 1 -d ,`
  scanid=`echo ${i} | cut -f 2 -d ,`

  # Now find the extracted ANTsCT image
  anatImage=`ls ${antsCTDir}${bblid}/*${scanid}/ExtractedBrain0N4.nii.gz`

  # Now find which images need to be loaded ontop of this
  # But first prep some output values
  gmdFlag=0
  gmdImage=""
  ctFlag=0
  ctImage=""
  antsFlag=0
  antsImage=""
  jlfFlag=0
  jlfImage=""
  flagEcho="BBLID:${bblid} SCANID:${scanid} This image was flagged on:"

  # Now grep each of the outputs if the exit status is 0 then we know
  # we won't need to laod that image
  grep ${i} ${inFileGMD}
  if [ $? -eq 0 ] ; then
    flagEcho="${flagEcho} GMD"
    gmdImage=`ls ${antsCTDir}${bblid}/*${scanid}/${bblid}_*${scanid}*GMDValues_prob02.nii.gz` 
    gmdFlag=1 ; 
  fi
  grep ${i} ${inFileCT}
  if [ $? -eq 0 ] ; then
    flagEcho="${flagEcho} CT"
    ctImage=`ls ${antsCTDir}${bblid}/*${scanid}/CorticalThickness.nii.gz` 
    ctFlag=1 ; 
  fi
  grep ${i} ${inFileANTS}
  if [ $? -eq 0 ] ; then
    flagEcho="${flagEcho} ANTsCT Segmentation"
    antsImage=`ls ${antsCTDir}${bblid}/*${scanid}/BrainSegmentation.nii.gz` 
    antsFlag=1 ; 
  fi  
  grep ${i} ${inFileJLF}
  if [ $? -eq 0 ] ; then
    flagEcho="${flagEcho} JLF"
    jlfImage=`ls ${jlfDir}${bblid}/*${scanid}/*jlfLabels.nii.gz` 
    jlfFlag=1 ; 
  fi  
 
 # Now run the fslview command
 echo ${flagEcho}
 fslview ${anatImage} ${gmdImage} ${ctImage} ${gmImage} ${antsImage} ${jlfImage}

  # Now prompt user for useability for the flagged Images
  if [ ${gmdFlag} -eq 1 ] ; then
    echo "Enter if the GMD values are useable: 1 = Not useable 0 = useable"
    read gmdFlag ; 
  fi
  if [ ${ctFlag} -eq 1 ] ; then
    echo "Enter if the CT values are useable: 1 = Not useable 0 = useable"
    read ctFlag ; 
  fi   
  if [ ${antsFlag} -eq 1 ] ; then
    echo "Enter if the ANTsCT Segmentation values are useable: 1 = Not useable 0 = useable"
    read antsFlag ; 
  fi      
  if [ ${jlfFlag} -eq 1 ] ; then
    echo "Enter if the JLF Segmentation values are useable: 1 = Not useable 0 = useable"
    read jlfFlag ; 
  fi  
  echo "Is this data useable?: 1 = Not useable 0 = useable"
  read useable

  # Now ask if the user has any extra comments
  echo "Do you have any comments about this image?"
  echo "Comments can include but are not limited to:"
  echo "	Brain Extraction errors"
  echo "	Registration errors"
  echo "	Bias field issues"
  echo "	You are extremally bored..."
  read notes

  # Now echo the output
  echo "${startnum}, ${bblid}, ${scanid}, ${gmdFlag}, ${ctFlag}, ${bmFlag}, ${antsFlag}, ${jlfFlag}, ${useable}, ${notes}" >> ${outfile} 
  startnum=`echo ${startnum} + 1 | bc`
  echo ${startnum} > ${indexFile}; 
done

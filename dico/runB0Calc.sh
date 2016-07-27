#!/bin/bash

# This script was written to create all of the B0 maps whcih can be found in 
# /data/joy/BBL/studies/pnc/processedData/b0map
# It is just a rough for loop which runs Mark Elliot's dico_b0calc_v4_afgr.sh script
# AFGR edited Mark Elliots script to make sure it took the correct inputs




# Run through each subject and calcualte a b0 rps map for them
subjFile="/home/arosen/tempCohortListSplit/x${1}"
subjLength=`cat ${subjFile} | wc -l`
baseOutputPath="/data/joy/BBL/studies/pnc/processedData/b0mapwT2star/"
baseRawDataPath="/data/joy/BBL/studies/pnc/rawData/"
baseExtractedPath="/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/"
scriptToCall="/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/dico/dico_b0calc_v4_afgr.sh"
forceScript="/data/joy/BBL/applications/scripts/bin/force_RPI.sh"

for subj in `seq 1 ${subjLength}` ; do
  rndDig=${RANDOM}
  bblid=`sed -n "${subj}p" ${subjFile} | cut -f 1 -d ","`
  scanid=`sed -n "${subj}p" ${subjFile} | cut -f 2 -d ","`
  scandate=`sed -n "${subj}p" ${subjFile} | cut -f 3 -d ","`
  subjRawData="${baseRawDataPath}${bblid}/${scandate}x${scanid}"
  subjB0Maps=`find ${subjRawData} -name "B0MAP*" -type d`
  subjB0Maps1=`echo ${subjB0Maps} | cut -f 1 -d ' '`
  subjB0Maps2=`echo ${subjB0Maps} | cut -f 2 -d ' '`
  subjOutputDir="${baseOutputPath}/${bblid}/${scandate}x${scanid}/"
  mkdir -p ${subjOutputDir}
  rawT1=`find ${subjRawData}/*mprage* -name "*nii.gz" -type f`
  ${forceScript} ${rawT1} ./tmp${rndDig}.nii.gz
  rawT1="./tmp${rndDig}.nii.gz"
  extractedT1=`find ${baseExtractedPath}${bblid}/${scandate}x${scanid} -name "Extracted*nii.gz"`
  if [ -f ${subjOutputDir}${bblid}_${scandate}x${scanid}_rpsmap.nii ] ; then
    echo "output already exists"
    echo "Skipping BBLID:${bblid}"
    echo "	   SCANID:${scanid}"
    echo "         DATE:${scandate}"
    echo "*************************" ; 
  else
    ${scriptToCall} ${subjOutputDir} ${subjB0Maps1}/ ${subjB0Maps2}/ ${rawT1} ${extractedT1}   
    for i in `ls ${subjOutputDir}` ; do
      mv ${subjOutputDir}${i} ${subjOutputDir}${bblid}_${scandate}x${scanid}${i} 
    done ;
    for i in `ls ${subjOutputDir}*nii` ; do 
      /share/apps/fsl/5.0.8/bin/fslchfiletype NIFTI_GZ ${i} ; 
    done   
  fi  
  rm ${rawT1} ;  
done
  
  
  
## Call this script like what can be seen below
##for i in 0{0..9} {10..43} ; do qsub ~/runB0Calc.sh ${i} ; done
## That is all


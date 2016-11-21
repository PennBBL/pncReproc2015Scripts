#!/bin/bash
subjlist=${1}
#subjlist=$(cat $subjlist | sed -n "${SGE_TASK_ID}p")

for subj in `cat ${subjlist}` ; do
  if [ ! -f /data/joy/BBL/studies/pnc/processedData/structural/jlf/${subj}/jlfLabels.nii.gz ] ; then
    /home/arosen/pncReproc2015Scripts/jlf/procScripts/antsJLF_OASIS30CustomSubset_afgr.pl /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${subj}/ExtractedBrain0N4.nii.gz /data/joy/BBL/studies/pnc/processedData/structural/jlf/${subj}/jlf 1 0 Younger24 & 
  sleep 30 ;
  else
    echo "All Done"
    exit 0 
  fi
done

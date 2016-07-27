subjlist=${1}
subj=$(cat $subjlist | sed -n "${SGE_TASK_ID}p")


for subjName in `cat $subjlist` ; do
  if [ ! -f /data/joy/BBL/studies/pnc/processedData/structural/jlf/${subjName}/*jlfLabels.nii.gz ] ; then
    /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/scripts/antsJLF_OASIS30CustomSubset_afgr-basic-slay.pl /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${subjName}/ExtractedBrain0N4.nii.gz /data/joy/BBL/studies/pnc/processedData/structural/jlf/${subjName}/jlf 1 1 Younger24 &
  sleep 120
  else
    echo "All Done"
  fi ;
done

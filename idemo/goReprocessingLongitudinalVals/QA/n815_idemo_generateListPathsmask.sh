cat /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_bblidscanid_list.csv | while read line
do
  bblid=`echo $line | cut -d "," -f1`;
  scanid=`echo $line | cut -d "," -f2`;
  path=`ls -d /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/${bblid}/*${scanid}/norm/*_maskStd.nii.gz`;
  echo $bblid,$scanid,$path >> /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_idemo_listMask.csv
done

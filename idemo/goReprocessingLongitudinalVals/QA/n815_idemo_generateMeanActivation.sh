
cat /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_bblidscanid_list.csv | while read line
do
    id=`echo $line | cut -d "," -f1`;
    scanid=`echo $line | cut -d "," -f2`;
    i=`ls -d /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/${id}/*${scanid}/norm/*sigchange_cope1_TaskStd.nii.gz`;
    meanAct=`fslstats $i -k /data/joy/BBL/projects/pncReproc2015/idemo/QA/idemoTaskTstatThr10Mask.nii.gz -M`;
    echo $id,$scanid,$meanAct >> /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_idemo_MeanActivation.csv
done

path=`ls -d /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/*/*/task/mc/*_rel_rms.1D`;

for line in $path; do
    id=`echo $line | cut -d "/" -f10`;
    scanid=`echo $line | cut -d "/" -f11`;
    scanid=`echo $scanid | cut -d "x" -f2`;
     echo $id,$scanid,$line >> /data/joy/BBL/projects/pncReproc2015/idemo/QA/n1601_idemo_MaxRMS_subjectList.csv

done


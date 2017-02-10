for line in $(cat /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_bblidscanid_list.csv); do 
        id=`echo $line | cut -d "," -f1`;
        echo $id;
        scanid=`echo $line | cut -d "," -f2`;
        echo $scanid; 
        i=`ls -d /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/${id}/*${scanid}/task/mc/*_rel_rms.1D`;
        echo $id,$scanid,$i >> /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_idemo_listofRelrmsFiles.csv;
done


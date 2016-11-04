scanids=$(cat /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/ravens/failedpipeline.csv |cut -d',' -f1-2); 

for i in $scanids; do 
    id=$(echo $i|cut -d',' -f1); 
    sc=$(echo $i|cut -d',' -f2);
    path=`ls -d /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${id}/*${sc}/`;
    dtxsc=$(echo $path |cut -d'/' -f11);
    mkdir /data/joy/BBL/studies/pnc/processedData/structural/ravens/${id}/
    mkdir /data/joy/BBL/studies/pnc/processedData/structural/ravens/${id}/${dtxsc}/
echo ${id},${dtxsc} >> /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/ravens/n1601_failedPipeline_RavensRerun.csv; 
done


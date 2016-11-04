scanids=$(cat /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/n1601_summaryData/nback/n1601_NbackQAData.csv|cut -d',' -f1-2); 

for i in $scanids; do 
    id=$(echo $i|cut -d',' -f1); 
    sc=$(echo $i|cut -d',' -f2);
    path=`ls -d /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${id}/*${sc}/`;
    dtxsc=$(echo $path |cut -d'/' -f11);
echo ${id},${dtxsc} >> /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/ravens/N1601_Ravens_bblidScanid_201610.csv; 
done

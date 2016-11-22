scanids=$(cat /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/task/idemo/goReprocessingIdemo/n1601_xnatAudit_usableIdemo_2016Oct25.csv |cut -d',' -f1-2); 

for i in $scanids; do id=$(echo $i|cut -d',' -f1); 
    sc=$(echo $i|cut -d',' -f2); 
    im=$(ls /data/joy/BBL/studies/pnc/rawData/${id}/*${sc}/bbl1_idemo*/nifti/*${sc}*SEQ*.nii.gz);
    ct=$(ls -d1 /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${id}/*${sc}*); 
    mag=$(ls /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/${id}/*${sc}*/*_mag1_brain.nii.gz); 
    rps=$(ls /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/${id}/*${sc}*/*_rpsmap.nii.gz); 
    sc=$(echo $im | cut -d '/' -f9);
    [[ -z ${im} ]] && continue;  
echo ${id},${sc},${im},${ct},${mag},${rps} >> cohort_idemo_2016Oct25.csv; 
done

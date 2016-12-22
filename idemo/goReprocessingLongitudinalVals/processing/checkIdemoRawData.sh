scanids=$(cat /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/n2416_listIdemo_xnatAudit.csv  |cut -d',' -f1-2); 

for i in $scanids; do 
    id=$(echo $i|cut -d',' -f1); 
    sc=$(echo $i|cut -d',' -f2); 
    im=$(ls /data/joy/BBL/studies/pnc/rawData/${id}/*${sc}/*bbl1_idemo*/nifti/*${sc}*idemo*.nii.gz);
    echo ${id},${sc},${im} >> n2416_IdemoCheckData.csv
done


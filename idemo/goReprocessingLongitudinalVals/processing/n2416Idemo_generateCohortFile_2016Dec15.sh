scanids=$(ls  -d /data/joy/BBL/studies/pnc/rawData/*/*/*bbl1_idemo2_210/nifti/*idemo*.nii.gz); 

for i in $scanids; do id=$(echo $i|cut -d',' -f1); 
    id=$(echo $i|cut -d'/' -f8); 
    sc=$(echo $i|cut -d'/' -f9); 
    sc=$(echo $sc|cut -d'x' -f2);
    im=$(ls /data/joy/BBL/studies/pnc/rawData/${id}/*${sc}/*bbl1_idemo*/nifti/*${sc}*idemo*.nii.gz);
    ct=$(ls -d1 /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${id}/*${sc}*); 
    mag=$(ls /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/${id}/*${sc}*/*_mag1_brain.nii.gz); 
    rps=$(ls /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/${id}/*${sc}*/*_rpsmap.nii.gz); 
    sc=$(echo $im | cut -d '/' -f9);
    [[ -z ${im} ]] && continue;  
echo ${id},${sc},${im},${ct},${mag},${rps} >> n2416Idemo_cohortFile_2016Dec15.csv; 
done

scanids=$(ls  -d /data/joy/BBL/studies/pnc/rawData/*/*/*bbl1_idemo2_210/nifti/*idemo*.nii.gz); 

for i in $scanids; do 
    id=$(echo $i|cut -d'/' -f8); 
    sc=$(echo $i|cut -d'/' -f9); 
    sc=$(echo $sc|cut -d'x' -f2);
    im=$(ls /data/joy/BBL/studies/pnc/rawData/${id}/*${sc}/*bbl1_idemo*/nifti/*${sc}*idemo*.nii.gz);
echo ${id},${sc},${im} >> n2416_idemo_listRawNifti.csv; 
done

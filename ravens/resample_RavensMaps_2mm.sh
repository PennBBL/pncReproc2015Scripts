
for i in /data/joy/BBL/studies/pnc/processedData/structural/ravens/*/*/*_RAVENS_2.nii.gz; do 

root=/data/joy/BBL/studies/pnc/processedData/structural/ravens
id=`echo $i | cut -d "/" -f10`; 
sc=`echo $i | cut -d "/" -f11`;

root=`echo ${root}/${id}/${sc}`;
sc=`echo $sc | cut -d "x" -f2`;
outName=`echo ${root}/${id}_${sc}_RAVENS_2GM_2mm.nii.gz`;

antsApplyTransforms -i ${i} -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o $outName

echo ' 

';
done


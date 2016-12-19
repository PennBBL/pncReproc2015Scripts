## Post Processing Script for RAVENS
## Resample RAVENS GM map to 2mm 

## Take all RAVENS GM 1mm Maps
for i in /data/joy/BBL/studies/pnc/processedData/structural/ravens/*/*/*_RAVENS_2.nii.gz; do 


##Get BBLID and SCANID
root=/data/joy/BBL/studies/pnc/processedData/structural/ravens
id=`echo $i | cut -d "/" -f10`; 
sc=`echo $i | cut -d "/" -f11`;


root=`echo ${root}/${id}/${sc}`;
sc=`echo $sc | cut -d "x" -f2`;
outName=`echo ${root}/${id}_${sc}_RAVENS_2GM_2mm.nii.gz`;


#USE ANTS Apply Transform to resample this to 2mm space 
antsApplyTransforms -i ${i} -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o $outName

echo ' 

';
done


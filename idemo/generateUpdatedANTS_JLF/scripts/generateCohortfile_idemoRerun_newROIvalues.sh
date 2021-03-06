cat /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingUpdatedROiVals/n1601_xnatAudit_usableIdemo_2016Oct25.csv | while read line
do
   bblid=`echo $line | cut -d "," -f1`;
   scanid=`echo $line | cut -d "," -f2`;
   nifti=` ls -d /data/joy/BBL/studies/pnc/rawData/${bblid}/*${scanid}/*idemo2*/nifti/*${scanid}*SEQ*.nii.gz`
   echo $nifti
   scanid=` echo $nifti | cut -d "/" -f9`;
   ants=` ls -d /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${bblid}/*${scanid}`
   echo $ants
   mag=` ls -d /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/${bblid}/*${scanid}/*_mag1_brain.nii.gz`
   echo $mag
   rpsmap=` ls -d /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/${bblid}/*${scanid}/*_rpsmap.nii.gz`
   echo $rpsmap
   echo $bblid,$scanid,$nifti,$ants,$mag,$rpsmap >> cohort_file_IdemoUpdatedROI_2016Dec05.csv; 
done




##First Iteration All Subjects to find Inclusion Points

path=`ls /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/*/*/norm/*_maskStd*`;
fslmerge -t /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/concatenated_maskStd.nii.gz $path
fslmaths /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/concatenated_maskStd.nii.gz -Tmean /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_Mean_maskStd.nii.gz
fslmaths /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_Mean_maskStd.nii.gz -mul 1502 /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_Mean_maskStd.nii.gz



#Second Iteration: Creating Coverage mask

path=""
cat /data/joy/BBL/projects/pncReproc2015/idemo/maskCoverageInclude_Subjects.csv | while read line
do
   id=`echo $line | cut -d "," -f1`;
   scanid=`echo $line | cut -d "," -f2`;
   temp=`ls -d /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/${id}/*${scanid}/norm/*_maskStd*`;
   path=`echo $path $temp`;
   echo $temp
   echo $path > /data/joy/BBL/projects/pncReproc2015/idemo/listofMasksForCoverageMask.txt
done

path=`cat /data/joy/BBL/projects/pncReproc2015/idemo/listofMasksForCoverageMask.txt `
fslmerge -t /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_CoverageMask.nii.gz $path

fslmaths /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_CoverageMask.nii.gz -Tmean /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_CoverageMask.nii.gz

fslmaths /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_CoverageMask.nii.gz -thr 1 /data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_CoverageMask.nii.gz


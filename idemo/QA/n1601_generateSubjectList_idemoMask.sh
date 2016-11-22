for i in /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/*/*/norm/*_maskStd*; do 

id=`echo $i | cut -d "/" -f10`; 
scanid=`echo $i | cut -d "/" -f11`;
scanid=`echo $scanid | cut -d "x" -f2`;

echo $id,$scanid,$i >> /data/joy/BBL/projects/pncReproc2015/idemo/n1601_pnc_idemo_subjectlist.csv; 
done


for i in /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/*/*; do 

echo $i;
roiquant=`ls -d ${i}/roiquant`;
echo $roiquant;
rm -rf $roiquant;

roi=`ls -d ${i}/*_roi`;
echo $roi;
rm -rf $roi;

done

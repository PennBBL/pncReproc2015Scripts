cat /data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_jlfAntsCTIntersectionVol_20170323.csv | while read line
do
  bblid=`echo $line | cut -d "," -f1`;
  scanid=`echo $line | cut -d "," -f2`;
  path=`ls -d /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/${bblid}/*${scanid}/task/mc/*_rel_rms.1D`;
  echo $bblid,$scanid,$path >> //data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_listofMaxRMS.csv
done

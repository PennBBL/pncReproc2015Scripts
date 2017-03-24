##Quality Metrics

path=`ls -d /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/*/*/*_quality.csv`;
line=/data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/99991/20111222x6217/99991_20111222x6217_quality.csv
text=`cat $line`;
header=`echo $text | cut -d " " -f1`;
echo $header > /data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_idemo_QAMetrics.csv



for line in $path; do
    text=`cat $line`;
    qaMetrics=`echo $text | cut -d " " -f2`;
    echo $qaMetrics >> /data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_idemo_QAMetrics.csv;
done
    







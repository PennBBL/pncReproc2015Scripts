
line=/data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/99991/*x6217/99991*x6217_quality.csv
text=`cat $line`;
header=`echo $text | cut -d " " -f1`;
echo $header > /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_idemo_QAMetrics.csv



for line in $(cat /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_bblidscanid_list.csv); do 
        id=`echo $line | cut -d "," -f1`;
        echo $id;
        scanid=`echo $line | cut -d "," -f2`;
        echo $scanid; 
        i=`ls -d /data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/${id}/*${scanid}/*_quality.csv`;
        echo $i;
        if [ -z "$i" ]
        then
                echo $id,$scanid >> /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_idemo_QAMetrics.csv;
        else
                text=`cat $i`;
                echo $text
                qaMetrics=`echo $text | cut -d " " -f2`;
                echo $qaMetrics >> /data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_idemo_QAMetrics.csv;
        fi
        
done


       

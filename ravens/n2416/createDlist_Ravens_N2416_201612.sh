
scanids=$(cat /data/joy/BBL/projects/pncReproc2015/ravens/n2416_analysis/n815_golongitudinal_subjects.csv |cut -d',' -f1-2); 

for i in $scanids; do 
    id=$(echo $i|cut -d',' -f1); 
    sc=$(echo $i|cut -d',' -f2);
    path=`ls -d /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${id}/*${sc}/`;
    dtxsc=$(echo $path |cut -d'/' -f11);
    
    DIR=`echo /data/joy/BBL/studies/pnc/processedData/structural/ravens/${id}/`;
    if [ ! -d "$DIR" ]; then
        mkdir $DIR;
    fi

    DIR=`echo /data/joy/BBL/studies/pnc/processedData/structural/ravens/${id}/${dtxsc}/`;
    if [ ! -d "$DIR" ]; then
        mkdir $DIR;
    fi

    echo ${id},${dtxsc} >> /data/joy/BBL/projects/pncReproc2015/ravens/n2416_analysis/N815_Ravens_bblidScanid_201612.csv; 

done



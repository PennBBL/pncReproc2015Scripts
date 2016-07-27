#for FreeSurfer longitudinal analyses it is necessary for the directory structure to be "non-nested" as it is on monstrum, i.e. freesurfer/bblid_datexscanid rather than freesurfer/bblid/datexscanid. This script symlinks the FreeSurfer chead directory structure to a different directory where it will be in the bblid_datexscanid structure and can be analyzed using qdec

for i in `ls -d /data/joy/BBL/studies/pnc/processedData/structural/freesurferLongitudinal/fsData/93856/*x*`; do

bblid=`echo $i | cut -d "/" -f 11`; 
datexscanid=`echo $i | cut -d "/" -f 12`; 

ln -s $i /data/joy/BBL/projects/pncReproc2015/freesurferLongitudinal/$bblid"_"$datexscanid;

done


#do the same but for the bblid.long directory

for i in `ls -d /data/joy/BBL/studies/pnc/processedData/structural/freesurferLongitudinal/fsData/93856`; do

bblid=`echo $i | cut -d "/" -f 11`; 

ln -s $i/$bblid".long" /data/joy/BBL/projects/pncReproc2015/freesurferLongitudinal/$bblid".long";

done

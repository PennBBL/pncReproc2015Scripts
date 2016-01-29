#!/usr/bin/env bash

#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #

################################################################### 
# Generate a list of all subjects to be run
################################################################### 

bblids=$(ls /data/jag/BBL/studies/pnc/rawData/)
scriptdir=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT
logdir=${scriptdir}/logs/

rm -rf cohort_list.csv
rm -rf ${logdir}/t1flag

for bblid in ${bblids}
   do
   ores=$(ls /data/jag/BBL/studies/pnc/rawData/${bblid}/)
   for ore in $ores
      do
      ore=$(echo $ore \
         |rev \
         |cut -d"/" -f1 \
         |rev)
         dovisit=$(echo $ore|cut -d"x" -f1)
         scanid=$(echo $ore|cut -d"x" -f2)
      t1exists=$(ls -d1 /data/jag/BBL/studies/pnc/rawData/${bblid}/${dovisit}x${scanid}/*mprage*/${bblid}_${dovisit}x${scanid}_t1.nii.gz)
      if [ ! -z "${t1exists}" ]
         then
         echo ${bblid},${scanid},${dovisit} >> cohort_list.csv
      else
         echo ${bblid},${scanid},${dovisit} >> ${logdir}/t1flag
      fi
   done
done

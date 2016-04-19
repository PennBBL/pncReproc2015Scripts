#!/usr/bin/env bash

OUTDIR=/data/joy/BBL/projects/pncReproc2015/antsCT

allsubj=$(ls ${OUTDIR})
rm -f logs/success
rm -f logs/memory

for subj in $allsubj
   do
   scans=$(ls ${OUTDIR}/$subj)
   bblid=$subj #$(echo $subj|rev|cut -d"/" -f1|rev)
   for scan in $scans
      do
      s=${OUTDIR}/${subj}/${scan}
      scanid=$(echo $s|rev|cut -d"/" -f1|rev|cut -d"x" -f2)
      dovisit=$(echo $s|rev|cut -d"/" -f1|rev|cut -d"x" -f1)
      outfiles=$(ls -d1 ${s}/sge/antsCT_sge.sh.o*)
      for o in $outfiles
         do
         oid=$(echo ${o}|rev|cut -d"." -f1|cut -d"o" -f1|rev)
         success=$(grep -i "Done with ANTs processing pipeline" ${o})
         memory=$(grep -i "Failed to allocate memory for image." ${o})
         noprog=$(grep -i "we can't find the antsRegistration program." ${o})
         if [[ ! -z $success ]]
            then
            echo "${bblid},${scanid},${dovisit}::${oid}" >> logs/success
         elif [[ ! -z $memory ]]
            then
            echo "${bblid},${scanid},${dovisit}::${oid}" >> logs/memory
         elif [[ ! -z $noprog ]]
            then
            rm -f ${o}
            rm -f ${s}/sge/antsCT_sge.sh.e${oid}
         fi
      done
   done
done

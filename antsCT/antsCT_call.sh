#!/usr/bin/env bash

#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #

################################################################### 
# First input is a list of subject identifiers
################################################################### 

cohortlist=$1

################################################################### 
# Second input is number of people submitting jobs
################################################################### 

nsub=$2

################################################################### 
# Third input is submitter identifier
################################################################### 

isub=$3

scriptdir=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT
logdir=${scriptdir}/logs/

allsubj=$(cat ${cohortlist})

i=0
for subj in ${allsubj}
   do
   dosub=$(expr ${i} % ${nsub})
   if [ "${dosub}" == "${isub}" ]
      then
      bblid=$(echo ${subj}|cut -d"," -f1)
      scanid=$(echo ${subj}|cut -d"," -f2)
      dovisit=$(echo ${subj}|cut -d"," -f3)
      echo "Processing ${bblid},${scanid}.${dovisit}"
      out=/data/jag/BBL/projects/pncReproc2015/antsCT/${bblid}/${dovisit}x${scanid}/
      #if [ ! -d ${out} ]
         #then
         echo "Processing ${bblid},${scanid}.${dovisit}" >> ${logdir}/antsCT_${isub}
         mkdir -p ${out}/sge
         qsub \
            -V \
            -l h_vmem=10G,s_vmem=10.0G \
            -cwd \
            -v ANTSPATH=/data/jag/BBL/applications/ants_20151007/bin \
            -S /bin/bash \
            -o ${out}/sge \
            -e ${out}/sge \
            antsCT_sge.sh ${bblid} ${scanid} ${dovisit}
      #fi
   fi
   i=$(expr ${i} + 1)
done

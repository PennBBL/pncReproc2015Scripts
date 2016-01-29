#!/usr/bin/env bash

#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #

################################################################### 
# First input is BBLID
################################################################### 

bblid=$1

################################################################### 
# Second input is scan ID
################################################################### 

scanid=$2

################################################################### 
# Third input is date of visit
################################################################### 

dovisit=$3

input=$(\ls -d1 /data/jag/BBL/studies/pnc/rawData/${bblid}/${dovisit}x${scanid}/*mprage*/${bblid}_${dovisit}x${scanid}_t1.nii.gz)

# On Dr. Phil Cook's recommendation, prior weight decremented from 0.25 to 0.2
/data/jag/BBL/applications/ants_20151007/bin/antsCorticalThickness.sh \
   -d 3 \
   -a ${input} \
   -e /data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/template.nii.gz \
   -m /data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/templateMask.nii.gz \
   -f /data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/templateMaskDil.nii.gz \
   -p /data/jag/BBL/projects/pncReproc2015/template/priors/renorm/prior_00%d.nii.gz \
   -w 0.2 \
   -t /data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/templateBrain.nii.gz \
   -o /data/jag/BBL/projects/pncReproc2015/antsCT/${bblid}/${dovisit}x${scanid}/

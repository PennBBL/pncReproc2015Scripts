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

input=$(\ls -d1 /data/joy/BBL/studies/pnc/rawData/${bblid}/${dovisit}x${scanid}/*mprage*/${bblid}_${dovisit}x${scanid}_t1.nii.gz)

# On Dr. Phil Cook's recommendation, prior weight decremented from 0.25 to 0.2
/data/joy/BBL/applications/ants_20151007/bin/antsCorticalThickness.sh \
   -d 3 \
   -a ${input} \
   -e /data/joy/BBL/studies/pnc/template/template.nii.gz \
   -m /data/joy/BBL/studies/pnc/template/templateMask.nii.gz \
   -f /data/joy/BBL/studies/pnc/template/templateMaskDil.nii.gz \
   -p /data/joy/BBL/studies/pnc/template/priors/prior_00%d.nii.gz \
   -w 0.2 \
   -t /data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz \
   -o /data/joy/BBL/projects/pncReproc2015/antsCT/${bblid}/${dovisit}x${scanid}/

#!/usr/bin/env bash

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################


###################################################################
# Identify whether any subjects are missing cortical thickness
# analysis from the ANTsCT pipeline
###################################################################


###################################################################
# Define inputs
allsubj=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT/cohort_list.csv
success=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT/logs/finImg
subjdir=/data/jag/BBL/projects/pncReproc2015/antsCT/
###################################################################


###################################################################
# Iterate through all subjects
###################################################################
allsubj=$(cat ${allsubj})
for s in ${allsubj}
   do
   ################################################################
   # Parse subject information
   ################################################################
   bblid=$(echo ${s}|cut -d"," -f1)
   scanid=$(echo ${s}|cut -d"," -f2)
   dovisit=$(echo ${s}|cut -d"," -f3)
   ################################################################
   # Find final image
   ################################################################
   sdir=${subjdir}/${bblid}/${dovisit}x${scanid}
   ctnorm=$(\ls ${sdir}/CorticalThicknessNormalizedToTemplate.nii*)
   ################################################################
   # Test final image existence and write positives to log
   ################################################################
   [[ ! -z "${ctnorm}" ]] && echo ${s} >> ${success}
done

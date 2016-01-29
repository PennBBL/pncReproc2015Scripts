#!/usr/bin/env bash

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################


###################################################################
# Determine which subjects failed the initial ANTsCT run
# Create a reduced cohort list including only those subjects
###################################################################


###################################################################
# Define inputs
allsubj=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT/cohort_list.csv
compl1=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT/logs/success
compl2=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT/logs/finImg
###################################################################


###################################################################
# Iterate through all subjects
###################################################################
rm -f reduced_cohort_list.csv
allsubj=$(cat ${allsubj})
for s in ${allsubj}
   do
   ################################################################
   # Determine whether logs and images indicate that the current
   # subject's data has been processed
   ################################################################
   logtest=$(grep -i ${s} ${compl1})
   imgtest=$(grep -i ${s} ${compl2})
   [[ -z ${logtest} ]] && test1="-" || test1="+"
   [[ -z ${imgtest} ]] && test2="-" || test2="+"
   if [[ "${test1}" == "-" ]] \
      || [[ "${test2}" == "-" ]]
      then
      echo ${s},${test1},${test2} >> reduced_cohort_list.csv
   fi
done

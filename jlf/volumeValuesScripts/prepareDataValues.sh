#!/bin/bash
#AFGR August 5 2016
# This script is going to be used to prep the data for the JLF volume and ANTsCT volume values

# Delcare any statics
jlfDirectory="/data/joy/BBL/studies/pnc/processedData/structural/jlf/"
jlfVolDir="/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/"
ctDirectory="/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/"
scriptsDir="/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/volumeValuesScripts"
subjInfoDir="/data/joy/BBL/studies/pnc/subjectData/"

# First thing we have to do is create the raw volume output for the jlf labels
rm -f ${jlfVolDir}jlfVolValues_20160805.txt
for i in `find ${jlfDirectory} -name "*jlfLabels.nii.gz"` ; do vals=`fslstats ${i} -H 208 0 207` ; echo ${i} ${vals} ; done >> ${jlfVolDir}jlfVolValues_20160805.txt

# Now do the antsCT values
rm -f ${jlfVolDir}ctVolValues_20160805.txt
for i in `find ${ctDirectory} -maxdepth 12 -name "BrainSegmentation.nii.gz"` ; do vals=`fslstats ${i} -H 7 0 6` ; echo ${i} ${vals} ; done >> ${jlfVolDir}ctVolValues_20160805.txt

# Now fix the subject fields using an *NON FLEXIBLE R SCRIPT*
R --slave -f ${scriptsDir}/prepSubjFields.R ${jlfVolDir}jlfVolValues_20160805.txt
R --slave -f ${scriptsDir}/prepSubjFields.R ${jlfVolDir}ctVolValues_20160805.txt

# Now I need to adjust the headers of the proper Subject field files 
R --slave -f ${scriptsDir}/prepVolHeader.R ${jlfVolDir}jlfVolValues_20160805properSubjFields.csv
R --slave -f ${scriptsDir}/prepCtHeader.R ${jlfVolDir}ctVolValues_20160805properSubjFields.csv

# Now I need to combine the manual ratings, jlf and ct values
R --slave -f ${scriptsDir}/combineAllVolVals.R ${jlfVolDir}jlfVolValues_20160805properSubjFieldsProperColNames.csv  ${jlfVolDir}ctVolValues_20160805properSubjFieldsProperColNames.csv ${subjInfoDir}n1601_t1RawManualQA.csv ${subjInfoDir}n368_t1RawManualQA_GO2.csv 

# Now clean up interim files
rm -f ${jlfVolDir}jlfVolValues_20160805.txt ${jlfVolDir}ctVolValues_20160805.txt ${jlfVolDir}jlfVolValues_20160805properSubjFields.csv ${jlfVolDir}ctVolValues_20160805properSubjFields.csv

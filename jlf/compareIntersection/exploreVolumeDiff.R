# AFGR November 28 2016
# This script is oging to be used to compare the masked vs unmasked JLF segmentation volumes.

## Load library(s)

## Now produce our volume values
# First the raw values
system("for i in `find /data/joy/BBL/studies/pnc/processedData/structural/jlf/ -name *jlfLabels.nii.gz` ; do vals=`fslstats ${i} -H 208 0 207` ; echo ${i} ${vals} ; done >> /data/joy/BBL/projects/pncReproc2015/jlf/compareValues/rawValues.1D")

## Now the masked values
system("for i in `find /data/joy/BBL/studies/pnc/processedData/structural/jlf/ -name *jlfLabelsANTsCTUnion.nii.gz` ; do vals=`fslstats ${i} -H 208 0 207` ; echo ${i} ${vals} ; done >> /data/joy/BBL/projects/pncReproc2015/jlf/compareValues/maskedValues.1D")

# Now I need to prep the headers for these files.. using the same files I have done this with previously
system("R --slave -f /home/arosen/pncReproc2015Scripts/jlf/volumeValuesScripts/prepSubjFields.R /data/joy/BBL/projects/pncReproc2015/jlf/compareValues/maskedValues.1D")
system("R --slave -f /home/arosen/pncReproc2015Scripts/jlf/volumeValuesScripts/prepSubjFields.R /data/joy/BBL/projects/pncReproc2015/jlf/compareValues/rawValues.1D")
system("R --slave -f /home/arosen/pncReproc2015Scripts/jlf/volumeValuesScripts/prepVolHeader.R /data/joy/BBL/projects/pncReproc2015/jlf/compareValues/maskedValuesproperSubjFields.csv")
system("R --slave -f /home/arosen/pncReproc2015Scripts/jlf/volumeValuesScripts/prepVolHeader.R /data/joy/BBL/projects/pncReproc2015/jlf/compareValues/rawValuesproperSubjFields.csv")

# Now load the values
rawVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/jlf/compareValues/rawValuesproperSubjFieldsProperColNames.csv')
maskedVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/jlf/compareValues/maskedValuesproperSubjFieldsProperColNames.csv')

# Now lets create our cor values
colnames(rawVals)[3:138] <- paste(colnames(rawVals)[3:138], '_old', sep='')
colnames(maskedVals)[3:138] <- paste(colnames(maskedVals)[3:138], '_new', sep='')
allVals <- merge(maskedVals, rawVals, by=c('subject.0.', 'subject.1.'))

# Now find the cor btn old and new cortical values
oldVals <- allVals[,grep('old', names(allVals))]
newVals <- allVals[,grep('new', names(allVals))]
corVals <- cor(oldVals[,39:136], newVals[,39:136])

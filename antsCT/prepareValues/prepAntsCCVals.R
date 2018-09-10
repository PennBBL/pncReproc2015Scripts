# AFGR August 14 2017

##Usage##
# This script will be used to prepare antsCT cortical contrst values
# for the JLF parcellation

# Load data
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')

# Create the data values
system(" for i in `find /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -name CortConVals.nii.gz -type f` ; do bblid=`echo ${i} | cut -f 10 -d /` ; dateid=`echo ${i} | cut -f 11 -d /` ; mask=`ls /data/joy/BBL/studies/pnc/processedData/structural/jlf/${bblid}/${dateid}/${bblid}_${dateid}_jlfLabelsANTsCTIntersection.nii.gz*` ; 3dROIstats -1DRformat -nzmean -numROI 208 -nomeanout -nobriklab -mask ${mask} ${i} >> /home/arosen/cortConVals/${bblid}_${dateid}_jlfCOrtConVals.1D ; done")
system("$XCPEDIR/utils/combineOutput -p /home/arosen/cortConVals/ -f jlfCOrtConVals.1D -o antsCT_JLF_CC_vals.1D")

# Now actually read the data 
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]
ctValues <- read.table('/home/arosen/cortConVals/antsCT_JLF_CC_vals.1D', header=T)
columnValues <- read.csv("/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/labelList/inclusionCheck.csv")
nzCols <- grep('NZMean', names(ctValues))
nzCols <- append(c(1), nzCols)

ctValues <- ctValues[,nzCols]

colsOfInterest <- columnValues$Label.Number[which(columnValues$CT==0)] + 1
colsOfInterest <- append(c(1), colsOfInterest)

# Now limit the PCASL values to just the columns of interest
ctValues <- ctValues[,colsOfInterest]

# Now change their names
columnNames <- gsub(x=gsub(x=columnValues$JLF.Column.Names, pattern='%MODALITY%', replacement='mprage'), pattern='%MEASURE%', replacement='cortcon')[which(columnValues$CT==0)]
colnames(ctValues)[2:length(ctValues)] <- as.character(columnNames)

# Now order and rename the files
ctValues$scanid <- strSplitMatrixReturn(strSplitMatrixReturn(ctValues$name, '/')[,11], 'x')[,2]
ctValues$name <- strSplitMatrixReturn(ctValues$name, '/')[,10]
colnames(ctValues)[1] <- 'bblid'

# Now prepare the data values
write.csv(ctValues, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/t1struct/n2416_jlfAntsCTIntersectionCortCon_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)

# Now do the n1601 data
n1601.ct.vals <- merge(n1601.subjs, ctValues, by=c('bblid', 'scanid'))
write.csv(n1601.ct.vals, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_jlfAntsCTIntersectionCortCon_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)

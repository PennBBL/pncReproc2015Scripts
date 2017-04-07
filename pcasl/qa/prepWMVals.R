#AFGR April 7th 2017

# This script will be used to put together the n2416 data and n1601 data of the WM pcasl values
# Should be very straight forward.
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
system('/home/arosen/xcpEngine/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/ -f "JLFWM_val_asl_quant_ssT1.1D" -o jlfWMSSVals.1D')
system("mv /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/jlfWMSSVals.1D /data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_20161202/")

# Load all data
n1601.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid.csv')
n2416.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n2416_bblid_scanid.csv')
name.values <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/labelList/inclusionCheckWMLobes.csv')
pcaslValues <- read.table('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_20161202/jlfWMSSVals.1D', header=T)

# Now prep the names 
colNames <- c('bblid', 'scanid', gsub(x=gsub(x=name.values$JLF.Column.Names, pattern="%MODALITY%", replacement="pcasl"), pattern="%MEASURE%", replacement="cbf"))
colnames(pcaslValues) <- colNames

# Now fix the scanid column
pcaslValues$scanid <- strSplitMatrixReturn(charactersToSplit=pcaslValues$scanid, splitCharacter='x')[,2]

# Now create our n2416 data frame
output.data <- merge(n2416.data, pcaslValues, by=c('bblid', 'scanid'), all.x=T)

# Write csv 
write.csv(output.data, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/asl/n2416_jlfWMPcasl_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)

# Now write n1601 csv
output.data <- merge(n1601.data, pcaslValues, by=c('bblid', 'scanid'), all.x=T)

#write csv
write.csv(output.data, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/asl/n1601_jlfWMPcasl_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)


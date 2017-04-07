# AFGR 5 April 2017

# This script will be used to prepare the WM lobular MD/TR values
# The input csv is prepared by the script found below and should be run prior 
# /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/diffusion/64DirDataPrep/prepAllCSV/prepAllCSV.sh

# Source afgr startup script
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')

# Load data
mdVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/diffusion/preprdWMLobularVal/merged.csv', header=F)
mdVals <- mdVals[,-15]
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]
columnNames <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/labelList/inclusionCheckWMLobes.csv')
namesToAdd <- gsub(x=gsub(x=columnNames$JLF.Column.Names, pattern='%MODALITY%', replacement='dti'), pattern='%MEASURE%', replacement='rd')

# Now fix the subject identifier column
mdVals[,1] <- strSplitMatrixReturn(strSplitMatrixReturn((strSplitMatrixReturn(strSplitMatrixReturn(mdVals[,1], 'subjects/')[,2], 'dti'))[,1], 'x')[,2], '_')

# Now fix the column names
colnames(mdVals) <- c('scanid', 'bblid', as.character(namesToAdd))

# Now I need to add rows for the subjects that do not have data for the n1601
output.df <- merge(n1601.subjs, mdVals, by=c('bblid', 'scanid'))
bblidToAdd <- n1601.subjs$bblid[which(n1601.subjs$bblid %in% output.df$bblid == 'FALSE')]
scanidToAdd <- n1601.subjs$scanid[which(n1601.subjs$scanid %in% output.df$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, length(bblidToAdd) * (ncol(output.df)-2)), nrow=length(bblidToAdd), ncol=(ncol(output.df)-2)))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(output.df)
output.df <- rbind(output.df, tmpToAdd)
output.df <- output.df[!duplicated(output.df),]

# Now write the csv
write.csv(output.df, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_jlfWmLobesRDValues_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)

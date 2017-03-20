#!/usr/bin/env Rscript

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################
require(optparse)
require(pracma)

###################################################################
# Parse arguments to script, and ensure that the required arguments
# have been passed.
###################################################################
option_list = list(
   make_option(c("-r", "--roi"), action="store", default=NA, type='character',
              help="The name of the ROI system. You will want either
                     'JLF' or 'GlasserPNC'."),
   make_option(c("-o", "--out"), action="store", default=NA, type='character',
              help="The output path.")
)
opt = parse_args(OptionParser(option_list=option_list))

if (is.na(opt$roi)) {
   cat('User did not specify an input RoI.\n')
   cat('Use mergeROIvals.R -h for an expanded usage menu.\n')
   quit()
}
if (is.na(opt$roi)) {
   cat('User did not specify an output path.\n')
   cat('Use mergeROIvals.R -h for an expanded usage menu.\n')
   quit()
}
sink(file = '/dev/null')
roiName <- opt$roi
opath <- opt$out

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################

dir <- getwd()
odir <- '/data/joy/BBL/projects/pncReproc2015/restbold/quality'
rdir <- '/data/joy/BBL/projects/pncReproc2015/template/roinames/'

colNamesPath <- paste(rdir,paste(roiName,'_names.csv',sep=''),sep='/')
colIndexPath <- paste(rdir,paste(roiName,'_index.csv',sep=''),sep='/')
roiPaths <- paste(odir,paste('*ROI*',roiName,'*.txt',sep=''),sep='/')
roiPaths <- system(paste('ls',roiPaths),intern=T)

restVals <- read.csv(paste(dir,'n2416_IDs.csv',sep='/'))

columnNumbers <- as.numeric(read.csv(colIndexPath,header=F))
columnNames <- unlist(read.csv(colNamesPath,header=F))
measures <- unlist(read.table(paste(odir,'measures.csv',sep='/'),header=F))

for (p in 1:length(roiPaths)) {
   roiVals <- read.table(roiPaths[p])
   ################################################################
   # Add 2 in order to account for identifier buffer
   # (BBLID,DATExSCANID are first 2 fields)
   ################################################################
   indices <- c(1,2,columnNumbers + 2)
   roiVals <- roiVals[indices]
   ################################################################
   # Keep only scan IDs; discard dates of acquisition
   ################################################################
   roiVals$bblid <- roiVals$V1
   roiVals$scanid <- as.numeric(unlist(apply(roiVals[2],1,function(x) strsplit(as.character(x),split='x')))[c(T,F)])
   roiVals <- roiVals[,3:dim(roiVals)[2]]
   ################################################################
   # Rename all columns.
   ################################################################
   valNames <- gsub('%MEASURE%',measures[p],gsub('%MODALITY%','rest',columnNames))
   for (i in 1:length(valNames)) { names(roiVals)[i] <- valNames[i] }
   ################################################################
   # Merge and match by scan ID
   ################################################################
   restVals <- merge(restVals,roiVals,all.x=T)
}

write.csv(restVals,opath,row.names=F)
#data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')
#restVals1601 <- restVals[which(restVals$scanid %in% intersect(restVals$scanid,data$scanid)),]
#write.csv(restVals1601,paste('/data/joy/BBL/projects/pncReproc2015/restbold/quality/1601/1601',roiName,'rest',measures[1],'.csv',sep=''),row.names=F)


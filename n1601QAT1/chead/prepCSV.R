# source and load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
 
# Load the data
flagValues <- read.csv('/data/joy/BBL/projects/pncReproc2015/n1601QA/flaggingBasedonSD/n1601_go_QAFlags_Structural_final.csv')
t1QAData <- read.csv('/data/joy/BBL/projects/pncReproc2015/n1601QA/flaggingBasedonSD/n1601_t1RawManualQA.csv')
all.data <- merge(flagValues, t1QAData, by='scanid')
all.data <- all.data[which(all.data$averageRating!=0),]
 
qualityClasses <- unique(all.data$averageRating)
cols <- seq(4,17,1) 
totalOutput <- NULL
for(i in qualityClasses){
  # First create a tmpdf with just the values in our quality class
  tmp <- all.data[which(all.data$averageRating==i),]
  values<-NULL
  for(q in cols){
    value <- length(which(tmp[,q]==1))
    toCombine <- rbind(q, value)
    values <- cbind(values, toCombine) 
  }
  totalOutput <- rbind(totalOutput, values[2,])
}

rownames(totalOutput) <- qualityClasses
colnames(totalOutput) <- names(all.data)[cols]
sumColVals <- colSums(totalOutput)
totalOutput <- rbind(totalOutput, sumColVals)
sumRowVals <- rowSums(totalOutput)
totalOutput <- cbind(totalOutput, sumRowVals)

write.csv(totalOutput, '/data/joy/BBL/projects/pncReproc2015/n1601QA/flaggingBasedonSD/n1601_anatomicalFlagStatus.csv', quote=F, row.names=F)

# Now I need to prepare a list bblid and scanid's for each of the flagged images
# I will then feed this to a bash script to open up all of the images for each flag index
dataToQA <- all.data[which(all.data$finalFlag!=0),]

# Now I need to rm the images that were only flagged on cross corr
dataToQA <- dataToQA[-which(dataToQA$spatialCorrFlag==1 & dataToQA$finalFlag==1),]

# Now write a csv with all of the images to view
all.image.bblid.scanid <- cbind(dataToQA$bblid.x, dataToQA$scanid)
write.csv(all.image.bblid.scanid, '/data/joy/BBL/projects/pncReproc2015/n1601QA/allImageQA.csv', quote=F, row.names=F)
# Now do it for JLF
jlf.data <- dataToQA[which(dataToQA$JLFVolROIFlag!=0 | dataToQA$JLFVolLateralFlag!=0 ),]
jlf.output <- cbind(jlf.data$bblid.x, jlf.data$scanid)
write.csv(jlf.output, '/data/joy/BBL/projects/pncReproc2015/n1601QA/jlfImageQA.csv', quote=F, row.names=F)

# Now do CT data
ct.data <- dataToQA[which(dataToQA$JLFCTROIFlag!=0 | dataToQA$JLFCTLateralFlag!=0 ),]
ct.output <- cbind(ct.data$bblid.x, ct.data$scanid)
write.csv(ct.output, '/data/joy/BBL/projects/pncReproc2015/n1601QA/ctImageQA.csv', quote=F, row.names=F)

# Now do brain mask flag
bm.data <- dataToQA[which(dataToQA$brainMaskFlag!=0),]
bm.output <- cbind(bm.data$bblid.x, bm.data$scanid)
write.csv(bm.output, '/data/joy/BBL/projects/pncReproc2015/n1601QA/bmImageQA.csv', quote=F, row.names=F)

# Now do CSF GM WM DGM BS and CEREBELLUM
ants.data <- dataToQA[which(dataToQA$flagmprage_antsCT_vol_CSF!=0 | dataToQA$flagmprage_antsCT_vol_GrayMatter!=0 | dataToQA$flagmprage_antsCT_vol_WhiteMatter!=0 | dataToQA$flagmprage_antsCT_vol_DeepGrayMatter!=0 | dataToQA$flagmprage_antsCT_vol_BrainStem!=0 | dataToQA$flagmprage_antsCT_vol_Cerebellum!=0),]
ants.output <- cbind(ants.data$bblid.x, ants.data$scanid)
write.csv(ants.output, '/data/joy/BBL/projects/pncReproc2015/n1601QA/antsImageQA.csv', quote=F, row.names=F)

# Now do the gmd
gmd.data <- dataToQA[which(dataToQA$gmdGMFlag!=0),]
gmd.output <- cbind(gmd.data$bblid.x, gmd.data$scanid)
write.csv(gmd.output, '/data/joy/BBL/projects/pncReproc2015/n1601QA/gmdImageQA.csv', quote=F, row.names=F)

# source and load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
 
# Load the data
flagValues <- read.csv('/data/joy/BBL/projects/pncReproc2015/n2416QAT1/flaggingBasedonSD/n2416_go_QAFlags_Structural_final_2016Dec12.csv')
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]

# Now I need to rm all of the Go1 images
flagValues <- flagValues[!flagValues$scanid %in% n1601.subjs$scanid,]

# Now I need to rm the images that were only flagged on cross corr
dataToQA <- flagValues[which(flagValues$finalFlag!=0),]

# Now write a csv with all of the images to view
all.image.bblid.scanid <- cbind(dataToQA$bblid, dataToQA$scanid)
write.csv(all.image.bblid.scanid, '/data/joy/BBL/projects/pncReproc2015/n2416QAT1/flaggingBasedonSD/allImageQA.csv', quote=F, row.names=F)
# Now do it for JLF
jlf.data <- dataToQA[which(dataToQA$outlierROIJLF!=0 | dataToQA$outlierROIJLFLat!=0 ),]
jlf.output <- cbind(jlf.data$bblid, jlf.data$scanid)
write.csv(jlf.output, '/data/joy/BBL/projects/pncReproc2015/n2416QAT1/flaggingBasedonSD/jlfImageQA.csv', quote=F, row.names=F)

# Now do CT data
ct.data <- dataToQA[which(dataToQA$outlierROIJLFCt!=0 | dataToQA$outlierROICtLat!=0 ),]
ct.output <- cbind(ct.data$bblid, ct.data$scanid)
write.csv(ct.output, '/data/joy/BBL/projects/pncReproc2015/n2416QAT1/flaggingBasedonSD/ctImageQA.csv', quote=F, row.names=F)

# Now do CSF GM WM DGM BS and CEREBELLUM
ants.data <- dataToQA[which(dataToQA$mprage_antsCT_vol_CSF!=0 | dataToQA$mprage_antsCT_vol_GrayMatter!=0 | dataToQA$mprage_antsCT_vol_WhiteMatter!=0 | dataToQA$mprage_antsCT_vol_DeepGrayMatter!=0 | dataToQA$mprage_antsCT_vol_BrainStem!=0 | dataToQA$mprage_antsCT_vol_Cerebellum!=0),]
ants.output <- cbind(ants.data$bblid, ants.data$scanid)
write.csv(ants.output, '/data/joy/BBL/projects/pncReproc2015/n2416QAT1/flaggingBasedonSD/antsImageQA.csv', quote=F, row.names=F)

# Now do the gmd
gmd.data <- dataToQA[which(dataToQA$outlierROIJLF_GM!=0),]
gmd.output <- cbind(gmd.data$bblid, gmd.data$scanid)
write.csv(gmd.output, '/data/joy/BBL/projects/pncReproc2015/n2416QAT1/flaggingBasedonSD/gmdImageQA.csv', quote=F, row.names=F)

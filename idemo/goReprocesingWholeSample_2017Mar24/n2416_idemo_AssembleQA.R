###Creating Script to QA Final Values

##
data1601 <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_jlfAntsCTIntersectionVol_20170323.csv", header=F)
data1601 <- data1601[,1:2]
names(data1601) <- c("bblid","scanid")

#Read in Datasets
dataMeanAct <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_idemo_MeanActivation.csv", header=F)
dataMaskCov <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_maskCoverage_QA.csv")
dataQA <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_idemo_QAMetrics.csv")

#Data Manipulation to Merge
names(dataQA)[1:2] <- c("bblid","scanid")
names(dataMeanAct) <- c("bblid","scanid","meanAct")
dataQA$scanid <- as.character(dataQA$scanid)

for (i in 1:dim(dataQA)[1]) {
  dataQA$scanid[i] <- strsplit(dataQA$scanid[i], split = "x")[[1]][2]
}

#Get rid of paths column
dataMaskCov <- dataMaskCov[, c(1,2,4)]

#Read Max Dataset

maxDat <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_idemo_MaxRMS.csv")

#Merge Datasets
dataQA <- merge(dataQA, dataMaskCov, by=c("bblid", "scanid"))
dataQA <- merge(dataQA, dataMeanAct, by=c("bblid","scanid"))
dataQA <- merge(dataQA, maxDat, by=c("bblid","scanid"))
dataQA <- merge(data1601, dataQA, by=c("bblid", "scanid"), all.x = T)

dataQAout <- dataQA[, 1:2]

#Data Acquisition
dataQAout$Exclude.acquired <- 0
dataQAout$Exclude.acquired[is.na(dataQA$temporalSignalNoiseRatio)] <- 1

#VoxelWise Coverage
dataQAout$Exclude.Coverage <- 0
dataQAout$Exclude.Coverage[which(dataQA$QA.voxelCov != 4)] <- 1

#Mean Activation
sd(dataQA$meanAct, na.rm = T)
#0.1988382
mean(dataQA$meanAct, na.rm = T)
#0.2953447

dataQAout$Exclude.MeanAct <- 0
dataQAout$Exclude.MeanAct[which((dataQA$meanAct > 0.2953447 + (2*0.1988382)) | (dataQA$meanAct < 0.2953447 - (2*0.1988382)))] <- 1

#Max Rel Displacement
dataQAout$Exclude.MaxRel <- 0
dataQAout$Exclude.MaxRel[which(dataQA$maxQA > 6)] <- 1

#Mean Rel Displacement
dataQAout$Exclude.MeanRel <- 0
dataQAout$Exclude.MeanRel[which(dataQA$rel_mean_rms_motion > 0.5)] <- 1

dataQAout$excludeFinal <- rowSums(dataQAout[,3:7])
table(dataQAout$excludeFinal)

dataQAout$excludeFinal[which(dataQAout$excludeFinal > 0)] <- 1
write.csv(dataQAout, "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_idemo_FinalQA.csv", row.names=F)

data1601bblid <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n1601_cnb_wrat_scores_20161215.csv")
data1601bblid <- data1601bblid[,1:2]

dataQAout1601 <- merge(data1601bblid, dataQAout, by=c("bblid","scanid"))
write.csv(dataQAout1601, "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n1601_idemo_FinalQA.csv", row.names=F)

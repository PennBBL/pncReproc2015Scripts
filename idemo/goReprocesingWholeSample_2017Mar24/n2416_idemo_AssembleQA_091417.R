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

#Data Acquisition
dataQA$Exclude.acquired <- 0
dataQA$Exclude.acquired[is.na(dataQA$temporalSignalNoiseRatio)] <- 1

#VoxelWise Coverage
dataQA$Exclude.Coverage <- 0
dataQA$Exclude.Coverage[which(dataQA$QA.voxelCov != 4)] <- 1

#Mean Activation
sd(dataQA$meanAct, na.rm = T)
#0.1988382
mean(dataQA$meanAct, na.rm = T)
#0.2953447

dataQA$Exclude.MeanAct <- 0
dataQA$Exclude.MeanAct[which((dataQA$meanAct > 0.2953447 + (2*0.1988382)) | (dataQA$meanAct < 0.2953447 - (2*0.1988382)))] <- 1

#Max Rel Displacement
dataQA$Exclude.MaxRel <- 0
dataQA$Exclude.MaxRel[which(dataQA$maxQA > 6)] <- 1

#Mean Rel Displacement
dataQA$Exclude.MeanRel <- 0
dataQA$Exclude.MeanRel[which(dataQA$rel_mean_rms_motion > 0.5)] <- 1

dataQA$excludeFinal <- rowSums(dataQA[,12:16])
table(dataQA$excludeFinal)

names(dataQA)[11] <- "maxRMS"

dataQA$excludeFinal[which(dataQA$excludeFinal > 0)] <- 1
write.csv(dataQA, "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_idemo_FinalQA_091417.csv", row.names=F)

data1601bblid <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n1601_cnb_wrat_scores_20161215.csv")
data1601bblid <- data1601bblid[,1:2]

dataQA1601 <- merge(data1601bblid, dataQA, by=c("bblid","scanid"))
write.csv(dataQA1601, "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n1601_idemo_FinalQA_091417.csv", row.names=F)


## Generate ROI Values for QA Wiki

length(which(dataQA1601$Exclude.acquired == 0))

length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 1 & 
               dataQA1601$Exclude.MeanAct == 0 & 
               dataQA1601$Exclude.MaxRel == 0 &
               dataQA1601$Exclude.MeanRel == 0))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 0 & 
               dataQA1601$Exclude.MeanAct == 1 & 
               dataQA1601$Exclude.MaxRel == 0 &
               dataQA1601$Exclude.MeanRel == 0))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 0 & 
               dataQA1601$Exclude.MeanAct == 0 & 
               dataQA1601$Exclude.MaxRel == 1 &
               dataQA1601$Exclude.MeanRel == 0))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 0 & 
               dataQA1601$Exclude.MeanAct == 0 & 
               dataQA1601$Exclude.MaxRel == 0 &
               dataQA1601$Exclude.MeanRel == 1))

length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 1 & 
               dataQA1601$Exclude.MeanAct == 0 & 
               dataQA1601$Exclude.MaxRel == 1 &
               dataQA1601$Exclude.MeanRel == 0))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 1 & 
               dataQA1601$Exclude.MeanAct == 0 & 
               dataQA1601$Exclude.MaxRel == 0 &
               dataQA1601$Exclude.MeanRel == 1))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 1 & 
               dataQA1601$Exclude.MeanAct == 1 & 
               dataQA1601$Exclude.MaxRel == 0 &
               dataQA1601$Exclude.MeanRel == 0))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 0 & 
               dataQA1601$Exclude.MeanAct == 1 & 
               dataQA1601$Exclude.MaxRel == 1 &
               dataQA1601$Exclude.MeanRel == 0))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 0 & 
               dataQA1601$Exclude.MeanAct == 1 & 
               dataQA1601$Exclude.MaxRel == 0 &
               dataQA1601$Exclude.MeanRel == 1))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 0 & 
               dataQA1601$Exclude.MeanAct == 0 & 
               dataQA1601$Exclude.MaxRel == 1 &
               dataQA1601$Exclude.MeanRel == 1))

length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 1 & 
               dataQA1601$Exclude.MeanAct == 1 & 
               dataQA1601$Exclude.MaxRel == 1 &
               dataQA1601$Exclude.MeanRel == 0))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 1 & 
               dataQA1601$Exclude.MeanAct == 1 & 
               dataQA1601$Exclude.MaxRel == 0 &
               dataQA1601$Exclude.MeanRel == 1))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 0 & 
               dataQA1601$Exclude.MeanAct == 1 & 
               dataQA1601$Exclude.MaxRel == 1 &
               dataQA1601$Exclude.MeanRel == 1))
length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 1 & 
               dataQA1601$Exclude.MeanAct == 1 & 
               dataQA1601$Exclude.MaxRel == 1 &
               dataQA1601$Exclude.MeanRel == 1))


length(which(dataQA1601$Exclude.acquired == 0 & dataQA1601$Exclude.Coverage == 0 & 
               dataQA1601$Exclude.MeanAct == 0 & 
               dataQA1601$Exclude.MaxRel == 0 &
               dataQA1601$Exclude.MeanRel == 0))




## Generate ROI Values for QA Wiki

length(which(dataQA$Exclude.acquired == 0))

length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 1 & 
               dataQA$Exclude.MeanAct == 0 & 
               dataQA$Exclude.MaxRel == 0 &
               dataQA$Exclude.MeanRel == 0))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 0 & 
               dataQA$Exclude.MeanAct == 1 & 
               dataQA$Exclude.MaxRel == 0 &
               dataQA$Exclude.MeanRel == 0))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 0 & 
               dataQA$Exclude.MeanAct == 0 & 
               dataQA$Exclude.MaxRel == 1 &
               dataQA$Exclude.MeanRel == 0))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 0 & 
               dataQA$Exclude.MeanAct == 0 & 
               dataQA$Exclude.MaxRel == 0 &
               dataQA$Exclude.MeanRel == 1))

length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 1 & 
               dataQA$Exclude.MeanAct == 0 & 
               dataQA$Exclude.MaxRel == 1 &
               dataQA$Exclude.MeanRel == 0))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 1 & 
               dataQA$Exclude.MeanAct == 0 & 
               dataQA$Exclude.MaxRel == 0 &
               dataQA$Exclude.MeanRel == 1))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 1 & 
               dataQA$Exclude.MeanAct == 1 & 
               dataQA$Exclude.MaxRel == 0 &
               dataQA$Exclude.MeanRel == 0))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 0 & 
               dataQA$Exclude.MeanAct == 1 & 
               dataQA$Exclude.MaxRel == 1 &
               dataQA$Exclude.MeanRel == 0))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 0 & 
               dataQA$Exclude.MeanAct == 1 & 
               dataQA$Exclude.MaxRel == 0 &
               dataQA$Exclude.MeanRel == 1))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 0 & 
               dataQA$Exclude.MeanAct == 0 & 
               dataQA$Exclude.MaxRel == 1 &
               dataQA$Exclude.MeanRel == 1))

length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 1 & 
               dataQA$Exclude.MeanAct == 1 & 
               dataQA$Exclude.MaxRel == 1 &
               dataQA$Exclude.MeanRel == 0))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 1 & 
               dataQA$Exclude.MeanAct == 1 & 
               dataQA$Exclude.MaxRel == 0 &
               dataQA$Exclude.MeanRel == 1))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 0 & 
               dataQA$Exclude.MeanAct == 1 & 
               dataQA$Exclude.MaxRel == 1 &
               dataQA$Exclude.MeanRel == 1))
length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 1 & 
               dataQA$Exclude.MeanAct == 1 & 
               dataQA$Exclude.MaxRel == 1 &
               dataQA$Exclude.MeanRel == 1))


length(which(dataQA$Exclude.acquired == 0 & dataQA$Exclude.Coverage == 0 & 
               dataQA$Exclude.MeanAct == 0 & 
               dataQA$Exclude.MaxRel == 0 &
               dataQA$Exclude.MeanRel == 0))

length(which(dataQA$Exclude.acquired == 1 & dataQA$Exclude.MeanRel == 1))







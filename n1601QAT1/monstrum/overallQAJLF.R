##############################################################################
################                                               ###############
################          Overall 1601 Structural QA           ###############
################           Angel Garcia de la Garza            ###############
################              angelgar@upenn.edu               ###############
################                 10/05/2016                    ###############
##############################################################################


##############################################################################
## Volume ROI Flagging
##############################################################################


## Read in Data
dataQA <- read.csv("/import/monstrum/Users/angelgar/data/toQA-20160815.csv", as.is = T)
dataQAV2 <- read.csv("/import/monstrum/Users/angelgar/data/toQA-20160815_v2.csv", as.is = T)
dataQA[2185, 1:410] <- dataQAV2[which(dataQAV2$bblid == 105781), 1:410]
dataQA$norm_crosscorr[2185]  <- dataQAV2$norm_crosscorr[which(dataQAV2$bblid == 105781)]
dataQA$norm_coverage[2185]  <- dataQAV2$norm_coverage[which(dataQAV2$bblid == 105781)]


#Generate Dataset for Just 1601

dataQA$scanid <- 0
for (i in 1:dim(dataQA)[1]) {
  dataQA$scanid[i] <- strsplit(dataQA$datexscanid[i], "x")[[1]][2]
}

data1601 <- read.csv("~/data/n1601_go1_datarel_020716.csv")
data1601 <- data1601[c("bblid","scanid")]
dataQA <- merge(data1601, dataQA, by=c("bblid","scanid"))
dataQA <- dataQA[, -2]


##Generate JLF Dataset
dataJLF <- dataQA[, c(1:2, grep("jlf_vol", names(dataQA)))]
dataJLF$mean <- rowMeans(dataJLF[, 3:138])


##Create DataFrame for QA Values
dataOut <- as.data.frame(matrix(0, nrow=1601, ncol=139))

## For each ROI calculate mean and SD and flag outlier ROIs
for (i in 3:139) {
  meanJLF <- mean(dataJLF[,i], na.rm=T)
  sdJLF <- sd(dataJLF[,i], na.rm=T)
  dataOut[which((dataJLF[,i] > meanJLF + 2.5*sdJLF) | (dataJLF[,i] < meanJLF - 2.5*sdJLF)), i] <- 1
}

## Flag outliers of the number of flagged ROIs
names(dataOut) <- names(dataJLF)
dataOut[,1:2] <- dataJLF[,1:2]
dataOut$outlierROIJLF <- rowMeans(dataOut[,3:138])
dataOut$outlierROIFlag <- 0
meanOut <- mean(dataOut$outlierROIJLF)
sdOut <- sd(dataOut$outlierROIJLF)
dataOut$outlierROIFlag[which(dataOut$outlierROIJLF > meanOut + 2.5*sdOut)] <- 1


#create Final Dataset
dataFinal <- dataOut[c("bblid","datexscanid","outlierROIFlag")]
names(dataFinal)[3] <- "JLFVolROIFlag"

##############################################################################
## Volume Laterality Flagging
##############################################################################

dataOut <- as.data.frame(matrix(0, nrow=1601, ncol=139))

index <- grep("_R_", names(dataJLF))

#flag those that deviate in laterality 
for (i in index) {
  dataOut[,i] <- (dataJLF[,i] - dataJLF[,i + 1]) / (dataJLF[,i] + dataJLF[,i + 1])
  meanJLF <- mean(dataOut[,i])
  sdJLF <- sd(dataOut[,i])
  dataOut[which((dataOut[,i] > meanJLF + 2.5*sdJLF) | (dataOut[,i] < meanJLF - 2.5*sdJLF)), i + 1] <- 1
}


names(dataOut) <- names(dataJLF)
dataOut[, 1:2] <- dataJLF[,1:2]

dataOut <- dataOut[,c(1:2, index+1)]
for( i in 1:dim(dataOut)[2]) {
  names(dataOut)[i] <- gsub(pattern = "_L_", "_", names(dataOut)[i])
}


#Generate Means Across observations
dataOut$outlierROI <- rowMeans(dataOut[,3:66])
dataOut$outlierROIFlagLateralVol <- 0
meanOut <- mean(dataOut$outlierROI)
sdOut <- sd(dataOut$outlierROI)

dataOut$outlierROIFlagLateralVol[which(dataOut$outlierROI > meanOut + 2.5*sdOut)] <- 1

dataFinal.Temp <- dataOut[c("bblid","datexscanid","outlierROIFlagLateralVol")]
dataFinal <- merge(dataFinal, dataFinal.Temp, by=c("bblid","datexscanid"))
names(dataFinal)[4] <- "JLFVolLateralFlag"


##############################################################################
## Cortical Thickness ROI Flags
##############################################################################


#Generate 1601 Dataset
dataQA <- read.csv("/import/monstrum/Users/angelgar/data/toQA-20160815.csv", as.is = T)
dataQAV2 <- read.csv("/import/monstrum/Users/angelgar/data/toQA-20160815_v2.csv", as.is = T)
dataQA[2185, 1:410] <- dataQAV2[which(dataQAV2$bblid == 105781), 1:410]
dataQA$norm_crosscorr[2185]  <- dataQAV2$norm_crosscorr[which(dataQAV2$bblid == 105781)]
dataQA$norm_coverage[2185]  <- dataQAV2$norm_coverage[which(dataQAV2$bblid == 105781)]

dataQA$scanid <- 0
for (i in 1:dim(dataQA)[1]) {
  dataQA$scanid[i] <- strsplit(dataQA$datexscanid[i], "x")[[1]][2]
}

data1601 <- read.csv("~/data/n1601_go1_datarel_020716.csv")
data1601 <- data1601[c("bblid","scanid")]
dataQA <- merge(data1601, dataQA, by=c("bblid","scanid"))
dataQA <- dataQA[, -2]


dataJLF <- dataQA[, c(1:2, grep("jlf_ct", names(dataQA)))]
dataJLF$mean <- rowMeans(dataJLF[, 3:138])

dataOut <- as.data.frame(matrix(0, nrow=1601, ncol=139))

#CAlcualte mean and SD across all ROI
for (i in 3:139) {
  meanJLF <- mean(dataJLF[,i], na.rm=T)
  sdJLF <- sd(dataJLF[,i], na.rm=T)
  dataOut[which((dataJLF[,i] > meanJLF + 2.5*sdJLF) | (dataJLF[,i] < meanJLF - 2.5*sdJLF)), i] <- 1
}

names(dataOut) <- names(dataJLF)
dataOut[,1:2] <- dataJLF[,1:2]
dataOut$outlierROIJLF <- rowMeans(dataOut[,3:138])
dataOut$outlierROIFlag <- 0
meanOut <- mean(dataOut$outlierROIJLF)
sdOut <- sd(dataOut$outlierROIJLF)
dataOut$outlierROIFlag[which(dataOut$outlierROIJLF > meanOut + 2.5*sdOut)] <- 1

#Generate Flag and Merge with Final
dataFinal.Temp <- dataOut[c("bblid","datexscanid","outlierROIFlag")]
dataFinal <- merge(dataFinal, dataFinal.Temp, by=c("bblid","datexscanid"))
names(dataFinal)[5] <- "JLFCTROIFlag"

##############################################################################
## Cortical Thickness Laterality Flags
##############################################################################


dataOut <- as.data.frame(matrix(0, nrow=1601, ncol=139))

index <- grep("_R_", names(dataJLF))

#Calculate Outliers Across ROI
for (i in index) {
  dataOut[,i] <- (dataJLF[,i] - dataJLF[,i + 1]) / (dataJLF[,i] + dataJLF[,i + 1])
  meanJLF <- mean(dataOut[,i])
  sdJLF <- sd(dataOut[,i])
  dataOut[which((dataOut[,i] > meanJLF + 2.5*sdJLF) | (dataOut[,i] < meanJLF - 2.5*sdJLF)), i + 1] <- 1
}

names(dataOut) <- names(dataJLF)
dataOut[, 1:2] <- dataJLF[,1:2]

dataOut <- dataOut[,c(1:2, index+1)]
for( i in 1:dim(dataOut)[2]) {
  names(dataOut)[i] <- gsub(pattern = "_L_", "_", names(dataOut)[i])
}


#calculate overall outlier
dataOut$outlierROI <- rowMeans(dataOut[,3:66])
dataOut$outlierROIFlagLateralVol <- 0
meanOut <- mean(dataOut$outlierROI)
sdOut <- sd(dataOut$outlierROI)

dataOut$outlierROIFlagLateralVol[which(dataOut$outlierROI > meanOut + 2.5*sdOut)] <- 1


#Merge with Final 
dataFinal.Temp <- dataOut[c("bblid","datexscanid","outlierROIFlagLateralVol")]
dataFinal <- merge(dataFinal, dataFinal.Temp, by=c("bblid","datexscanid"))
names(dataFinal)[6] <- "JLFCTLateralFlag"



##############################################################################
## Spatial Correlation Flag
##############################################################################
dataQA$spatialCorrFlag <- 0
meanJLF <- mean(dataQA$norm_crosscorr)
sdJLF <- sd(dataQA$norm_crosscorr)
dataQA$spatialCorrFlag[dataQA$norm_crosscorr < meanJLF - 2.5*sdJLF] <- 1


##############################################################################
## Brain Mask Flag 
##############################################################################
dataQA$brainMaskFlag <- 0
meanJLF <- mean(dataQA$mprage_antsCT_vol_TBV)
sdJLF <- sd(dataQA$mprage_antsCT_vol_TBV)
dataQA$brainMaskFlag[(dataQA$mprage_antsCT_vol_TBV > meanJLF + 2.5*sdJLF) | (dataQA$mprage_antsCT_vol_TBV < meanJLF - 2.5*sdJLF)] <- 1



##############################################################################
## ANTS 6 Tissue Segmentation Flags 
##############################################################################
index <- grep("mprage_antsCT_vol_", names(dataQA))[1:6]

for (i in index) {
  dataQA[, dim(dataQA)[2] + 1]  <- 0
  meanJLF <- mean(dataQA[,i], na.rm=T)
  sdJLF <- sd(dataQA[,i], na.rm=T)
  dataQA[which((dataQA[,i] > meanJLF + 2.5*sdJLF) | (dataQA[,i] < meanJLF - 2.5*sdJLF)), dim(dataQA)[2] ] <- 1
}

names(dataQA)[422:427] <- paste0("flag", names(dataQA)[index])


##############################################################################
## GM CT Flag
##############################################################################
dataJLF <- dataQA[, c(1:2, grep("mprage_jlf_ct_", names(dataQA)))]

rois  <- c("WM","fornix","postlimbcerebr","corpus","InC","CSF","Vent", "Cer","Ves","Brain","Optic")
index <- 0
for (i in 1:length(rois)) {
  name  <- paste0("_", rois[i])
  index <- union(index, grep(name, names(dataJLF)))
}
index <- index[-1]
dataJLF$CT_gm <- rowMeans(dataJLF[,setdiff(3:138, index)], na.rm=T)

dataQA$meanCTGMFlag <- 0
meanJLF <- mean(dataJLF$CT_gm)
sdJLF <- sd(dataJLF$CT_gm)
dataQA$meanCTGMFlag[(dataJLF$CT_gm < meanJLF - 2.5*sdJLF) | (dataJLF$CT_gm > meanJLF + 2.5*sdJLF)] <- 1

dataFinal.Temp <- dataQA[c("bblid","datexscanid","meanCTGMFlag")]
dataFinal <- merge(dataFinal, dataFinal.Temp, by=c("bblid","datexscanid"))



##############################################################################
## Average GMD Flag
##############################################################################

dataQA1601 <- read.csv("~/jlfQA/n1601_averageGMDValues.csv")
dataQA1601 <- dataQA1601[,c(1,3)]

dataQA1601$gmdGMFlag <- 0
meanJLF <- mean(dataQA1601$averageGMD)
sdJLF <- sd(dataQA1601$averageGMD)
dataQA1601$gmdGMFlag[(dataQA1601$averageGMD < meanJLF - 2.5*sdJLF)] <- 1



## Merge all flags up until this point and create a final dataset 
dataFinal.Temp <- dataQA[, c(1,2, 420:427)]
dataFinal <- merge(dataFinal, dataFinal.Temp, by=c("bblid","datexscanid"))
dataQA1601 <- dataQA1601[, c(1,3)]
dataFinal <- merge(dataFinal, dataQA1601, all.y=T, by="bblid")

dataFinal$finalFlag <- rowSums(dataFinal[, c(3:16)])
dataFinal$scanid <- 0
for (i in 1:dim(dataFinal)[1]) {
  dataFinal$scanid[i] <- strsplit(dataFinal$datexscanid[i], "x")[[1]][2]
}

dataFinal <- dataFinal[, -2]

data1601 <- read.csv("~/data/n1601_go1_datarel_020716.csv")
data1601 <- data1601[c("bblid","scanid")]
dataFinal <- merge(data1601, dataFinal, all.x = T, by=c("bblid","scanid"))
dataFinal2 <- dataFinal

##############################################################################
## GMD ROI Flag
##############################################################################



#Create 1601 Dataset
dataQA <- read.csv("~/data/toQA-20160815.csv", as.is = T)
dataQAV2 <- read.csv("~/data/toQA-20160815_v2.csv", as.is = T)
dataQA[2185, 1:410] <- dataQAV2[which(dataQAV2$bblid == 105781), 1:410]
dataQA$norm_crosscorr[2185]  <- dataQAV2$norm_crosscorr[which(dataQAV2$bblid == 105781)]
dataQA$norm_coverage[2185]  <- dataQAV2$norm_coverage[which(dataQAV2$bblid == 105781)]

dataQA$scanid <- 0
for (i in 1:dim(dataQA)[1]) {
  dataQA$scanid[i] <- strsplit(dataQA$datexscanid[i], "x")[[1]][2]
}

data1601 <- read.csv("~/data/n1601_go1_datarel_020716.csv")
data1601 <- data1601[c("bblid","scanid")]
dataQA <- merge(data1601, dataQA, by=c("bblid","scanid"))
dataQA <- dataQA[, -2]


dataJLF <- dataQA[, c(1:2, grep("jlf_gmd", names(dataQA)))]
dataJLF$mean <- rowMeans(dataJLF[, 3:138])

dataOut <- as.data.frame(matrix(0, nrow=1601, ncol=139))

##Flag ROI
for (i in 3:139) {
  meanJLF <- mean(dataJLF[,i], na.rm=T)
  sdJLF <- sd(dataJLF[,i], na.rm=T)
  dataOut[which((dataJLF[,i] > meanJLF + 2.5*sdJLF) | (dataJLF[,i] < meanJLF - 2.5*sdJLF)), i] <- 1
}

names(dataOut) <- names(dataJLF)
dataOut[,1:2] <- dataJLF[,1:2]
dataOut$outlierROIJLF <- rowMeans(dataOut[,3:138])
dataOut$outlierROIFlag <- 0
meanOut <- mean(dataOut$outlierROIJLF)
sdOut <- sd(dataOut$outlierROIJLF)
dataOut$outlierROIFlag[which(dataOut$outlierROIJLF > meanOut + 2.5*sdOut)] <- 1

dataFinal <- dataOut[c("bblid","datexscanid","outlierROIFlag")]
names(dataFinal)[3] <- "JLFGMDROIFlag"

##############################################################################
## GMD Laterality Flag
##############################################################################

dataOut <- as.data.frame(matrix(0, nrow=1601, ncol=139))

index <- grep("_R_", names(dataJLF))

for (i in index) {
  dataOut[,i] <- (dataJLF[,i] - dataJLF[,i + 1]) / (dataJLF[,i] + dataJLF[,i + 1])
  meanJLF <- mean(dataOut[,i])
  sdJLF <- sd(dataOut[,i])
  dataOut[which((dataOut[,i] > meanJLF + 2.5*sdJLF) | (dataOut[,i] < meanJLF - 2.5*sdJLF)), i + 1] <- 1
}

names(dataOut) <- names(dataJLF)
dataOut[, 1:2] <- dataJLF[,1:2]

dataOut <- dataOut[,c(1:2, index+1)]
for( i in 1:dim(dataOut)[2]) {
  names(dataOut)[i] <- gsub(pattern = "_L_", "_", names(dataOut)[i])
}

dataOut$outlierROI <- rowMeans(dataOut[,3:66])
dataOut$outlierROIFlagLateralVol <- 0
meanOut <- mean(dataOut$outlierROI)
sdOut <- sd(dataOut$outlierROI)

#Flag Dataset
dataOut$outlierROIFlagLateralVol[which(dataOut$outlierROI > meanOut + 2.5*sdOut)] <- 1

dataFinal.Temp <- dataOut[c("bblid","datexscanid","outlierROIFlagLateralVol")]
dataFinal <- merge(dataFinal, dataFinal.Temp, by=c("bblid","datexscanid"))
names(dataFinal)[4] <- "JLFGMDLateralFlag"

#Clean Final dataset
table(dataFinal2$finalFlag)
dataFinal <- dataFinal[, -2]

dataFinal <- merge(dataFinal, dataFinal2, all.y=T, by="bblid")
dataFinal$finalFlag <- dataFinal$finalFlag + dataFinal$JLFGMDROIFlag + dataFinal$JLFGMDLateralFlag

table(dataFinal$finalFlag)

setdiff(dataFinal2$bblid[dataFinal2$finalFlag == 0], dataFinal$bblid[dataFinal$finalFlag == 0])

write.csv(dataFinal, "~/jlfQA/n1601_go_QAFlags_Structural_final.csv")

dataFinal$bblid[is.na(dataFinal$finalFlag)]

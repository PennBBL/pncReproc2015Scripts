#Read Data
data <- read.csv("/data/joy/BBL/projects/pncReproc2015/ravens/N1601_Ravens_MeanCT.csv")
names(data) <- c("bblid","scanid","meanGM","spaCorr")


### Missing Ravens 
data$missingRavens <- 0
data$missingRavens[is.na(data$meanGM)] <- 1

### Flag 2.5 +/- SD

data$flagQA_meanCT <- 0

sd.MeanCT <- sd(data$meanGM, na.rm = T)
mean.MeanCT <- mean(data$meanGM, na.rm=T)

data$flagQA_meanCT[which(data$meanGM > (mean.MeanCT + 2.5*sd.MeanCT) | data$meanGM < (mean.MeanCT -2.5*sd.MeanCT))] <- 1

## Flag 2.5 SD below correlation

data$flagQA_Corr <- 0
sd.Corr <- sd(data$spaCorr, na.rm = T)
mean.Corr <- mean(data$spaCorr, na.rm=T)
data$flagQA_Corr[which(data$spaCorr < (mean.Corr -2.5*sd.Corr))] <- 1


data$finalQA_ravens <- data$flagQA_meanCT + data$missingRavens + data$flagQA_Corr
data$finalQA_ravens[which(data$finalQA_ravens == 2)] <- 1

write.csv(data, "/data/joy/BBL/projects/pncReproc2015/ravens/N1601_Ravens_QA.csv", row.names=F)

##Post Processing Steps 
data2 <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1601_t1QaData.csv")

data <- merge(data, data2, by="bblid")

table(data$finalQA_ravens, data$t1Exclude)

bblid <- data$bblid[which(data$flagQA_meanCT == 1)]
data[which(data$bblid %in% bblid), ]
bblid <- data$bblid[order(data$spaCorr)[1:3]]
data[which(data$bblid %in% bblid), ]


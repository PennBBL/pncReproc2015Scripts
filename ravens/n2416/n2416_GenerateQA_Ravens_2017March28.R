#Read Data
data <- read.csv("/data/joy/BBL/projects/pncReproc2015/ravens/n2416_analysis/n2416_qa_meanCT_spaCorr.csv", header = F)
names(data) <- c("bblid","scanid","meanGM","spaCorr")


### Missing Ravens 
data$missingRavens <- 0
data$missingRavens[is.na(data$meanGM)] <- 1

### Flag 2.5 +/- SD

data$flagQA_meanCT <- 0

sd.MeanCT  <- 100.0331
mean.MeanCT <- 766.0938

data$flagQA_meanCT[which(data$meanGM > (mean.MeanCT + 2.5*sd.MeanCT) | data$meanGM < (mean.MeanCT -2.5*sd.MeanCT))] <- 1

## Flag 2.5 SD below correlation

data$flagQA_Corr <- 0
sd.Corr  <- 0.006017818
mean.Corr <- 0.9787415


data$flagQA_Corr[which(data$spaCorr < (mean.Corr -2.5*sd.Corr))] <- 1


data$finalQA_ravens <- data$flagQA_meanCT + data$missingRavens + data$flagQA_Corr
data$finalQA_ravens[which(data$finalQA_ravens == 2)] <- 1

write.csv(data, "/data/joy/BBL/projects/pncReproc2015/ravens/n2416_analysis/n2416_ravensQA_finalFile.csv", row.names=F)
write.csv(data, "/data/joy/BBL/studies/pnc/n2416_dataFreeze//neuroimaging/t1struct/ravens/n2416_Ravens_Qa.csv", row.names=F)


##Post Processing Steps 
#data[which(data$flagQA_meanCT == 1),1:2]
#data[which(data$spaCorr < .95),1:2]
#data2 <- read.csv("/data/joy/BBL/studies/pnc/n2416_dataFreeze//neuroimaging/t1struct//n2416_t1QaData_20170306.csv")
#datafinal <- merge(data,data2, by=c("bblid","scanid"))
#datafinal[which(data$spaCorr < .95), 8:9]
#datafinal[which(data$flagQA_meanCT == 1), 8:9]

data2 <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze//neuroimaging//t1struct//n1601_antsCtVol_20161006.csv")
data2 <- data2[c("bblid","scanid")]
datafinal <- merge(data2,data, by=c("bblid","scanid"))

write.csv(data, "/data/joy/BBL/studies/pnc/n1601_dataFreeze//neuroimaging/t1struct/ravens/n1601_Ravens_QA.csv", row.names=F)

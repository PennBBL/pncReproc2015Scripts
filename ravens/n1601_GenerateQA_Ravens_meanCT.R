
#Read Data
data <- read.csv("/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/ravens/N1601_Ravens_MeanCT.csv")
names(data) <- c("bblid","scanid","meanGM")


### Missing Ravens 
data$missingRavens <- 0
data$missingRavens[is.na(data$meanGM)] <- 1

### Flag 2.5 +/- SD

data$flagQA_meanCT <- 0

sd.MeanCT <- sd(data$meanGM, na.rm = T)
mean.MeanCT <- mean(data$meanGM, na.rm=T)

data$flagQA_meanCT[which(data$meanGM > (mean.MeanCT + 2.5*sd.MeanCT) | data$meanGM < (mean.MeanCT -2.5*sd.MeanCT))] <- 1

data$finalQA_ravens <- data$flagQA_meanCT + data$missingRavens

write.csv(data, "/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/ravens/N1601_Ravens_QA.cs")

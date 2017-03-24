data <- read.csv("//data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_listofMaxRMS.csv", header=F)
names(data) <- c("bblid","scanid","path")

data$maxQA <- 0
data$path <- as.character(data$path)

for (i in 1:dim(data)[1]) {
  if (data$path[i] == "") {
    data$maxQA[i] <- NA
  } else {
    temp <- read.csv(data$path[i], header=F)
    data$maxQA[i] <- max(temp[,1])
  }
}

data <- data[,c(1:2,4)]

write.csv(data, "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_idemo_MaxRMS.csv", row.names=F)

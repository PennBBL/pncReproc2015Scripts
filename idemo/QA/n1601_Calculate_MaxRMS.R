data <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/QA/n1601_idemo_MaxRMS_subjectList.csv", header=F)
names(data) <- c("bblid","scanid","path")

data$maxQA <- 0
data$path <- as.character(data$path)

for (i in 1:dim(data)[1]) {
  temp <- read.csv(data$path[i], header=F)
  data$maxQA[i] <- max(temp[,1])
}

data <- data[,c(1:2,4)]

write.csv(data, "/data/joy/BBL/projects/pncReproc2015/idemo/QA/n1601_idemo_MaxRMS.csv", row.names=F)

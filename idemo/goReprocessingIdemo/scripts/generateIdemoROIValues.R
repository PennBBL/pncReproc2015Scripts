#Glasser

data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_FinalQA.csv")


glasser <- as.data.frame(matrix(NA, ncol = 6000, nrow=1601))
namesglasser <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/pncTemplate/glasser/glasser_lookup.csv", header = F)
namesglasser$V1 <- as.character(namesglasser$V1)
namesglasser$V2 <- as.character(namesglasser$V2)

for (i in 1:1601) {
  glasser[i, 1:2] <- data[i, 1:2]
  path <- paste0("/data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/",data[i,1])
  datexscanid <- list.files(path)
  if (length(datexscanid) != 0) {
    path <- paste0(path,"/",datexscanid,"/roiquant/GlasserPNC/" )
    copes <- list.files(path)
    for (j in 1:length(copes)) {
      if (!grepl("nii.gz", copes[j])) {
        path.cope <- paste0(path, copes[j])
        temp.data <- read.csv(path.cope, sep = "\t")
        temp.data[1,5:364] <- temp.data[1,3:362]
        temp.data <- temp.data[,-c(3,4)]
        cope <- copes[j]
        if(i == 1) {
          for (k in 3:362) {
            name <- names(temp.data)[k]
            name <- strsplit(x = name, "_")[[1]][2]
            name <- namesglasser[which(namesglasser[,1] == name),2]
            copetemp <- strsplit(cope, "_cope")[[1]][2]
            copetemp <- strsplit(copetemp,".1D")[[1]][1]
            name <- paste0("idemo_glasser_cope",copetemp,"_",name)
            names(temp.data)[k] <- name
          }
        }

        glasser[i,(3 +(j-1)*360):(2 +(j)*360)] <-  as.numeric(temp.data[1,3:362])
        
        if (i == 1) {
          names(glasser)[(3 +(j-1)*360):(2 +(j)*360)] <- names(temp.data[,3:362])
        } 
      }   
    }
  }
  print(i)
}

names(glasser)[1:2] <- c("bblid","scanid")

index <- 0
for (i in 1:6000) {
  if (all(is.na(glasser[,i]))) {
    index <- c(index, i)
  }
}

index <- index[-1]
glasser <- glasser[,-index]

write.csv(glasser, "/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_glasser_roivals.csv", row.names=F)



#JLF
data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_FinalQA.csv")

jlf <- as.data.frame(matrix(NA, ncol = 3500, nrow=1601))
namesjlf <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/pncTemplate/jlf/jlf_lookup.csv", header = F)
namesjlf$V1 <- as.character(namesjlf$V1)
namesjlf$V2 <- as.character(namesjlf$V2)



for (i in 1:1601) {
  jlf[i, 1:2] <- data[i, 1:2]
  path <- paste0("/data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/",data[i,1])
  datexscanid <- list.files(path)
  if (length(datexscanid) != 0) {
    path <- paste0(path,"/",datexscanid,"/roiquant/JLF/" )
    copes <- list.files(path)
    for (j in 1:length(copes)) {
      if (!grepl("nii.gz", copes[j])) {
        
        path.cope <- paste0(path, copes[j])
        temp.data <- read.csv(path.cope, sep = "\t")
        temp.data[1,5:211] <- temp.data[1,3:209]
        temp.data <- temp.data[,-c(3,4)]
        cope <- copes[j]
        if(i == 1) {
          for (k in 3:209) {
            name <- names(temp.data)[k]
            name <- strsplit(x = name, "_")[[1]][2]
            name <- namesjlf[which(namesjlf[,1] == name),2]
            copetemp <- strsplit(cope, "_cope")[[1]][2]
            copetemp <- strsplit(copetemp,".1D")[[1]][1]
            name <- paste0("idemo_jlf_cope",copetemp,"_",name)
            names(temp.data)[k] <- name
          }
        }
        
        jlf[i,(3 +(j-1)*207):(2 +(j)*207)] <-  as.numeric(temp.data[1,3:209])
        
        if(i == 1) {
          names(jlf)[(3 +(j-1)*207):(2 +(j)*207)] <- names(temp.data[,3:209])
        }
        
      }   
    }
  }
  print(i)
}

names(jlf)[1:2] <- c("bblid","scanid")

index <- 0
for (i in 1:2500) {
  if (all(is.na(jlf[,i]))) {
    index <- c(index, i)
  }
}

index <- index[-1]
jlf <- jlf[,-index]

write.csv(jlf, "/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_jlf_roivals.csv", row.names=F)



#JLF Intersect
data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_FinalQA.csv")

jlf.intersect <- as.data.frame(matrix(NA, ncol = 3500, nrow=1601))
namesjlf <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/pncTemplate/jlf/jlf_lookup.csv", header = F)
namesjlf$V1 <- as.character(namesjlf$V1)
namesjlf$V2 <- as.character(namesjlf$V2)



for (i in 1:1601) {
  jlf.intersect[i, 1:2] <- data[i, 1:2]
  path <- paste0("/data/joy/BBL/studies/pnc/processedData/idemo/idemo_201610/",data[i,1])
  datexscanid <- list.files(path)
  if (length(datexscanid) != 0) {
    path <- paste0(path,"/",datexscanid,"/roiquant/JLFintersect/" )
    copes <- list.files(path)
    for (j in 1:length(copes)) {
      if (!grepl("nii.gz", copes[j])) {
        
        path.cope <- paste0(path, copes[j])
        temp.data <- read.csv(path.cope, sep = "\t")
        temp.data[1,5:211] <- temp.data[1,3:209]
        temp.data <- temp.data[,-c(3,4)]
        cope <- copes[j]
        if(i == 1) {
          for (k in 3:209) {
            name <- names(temp.data)[k]
            name <- strsplit(x = name, "_")[[1]][2]
            name <- namesjlf[which(namesjlf[,1] == name),2]
            copetemp <- strsplit(cope, "_cope")[[1]][2]
            copetemp <- strsplit(copetemp,".1D")[[1]][1]
            name <- paste0("idemo_jlf_intersect_cope",copetemp,"_",name)
            names(temp.data)[k] <- name
          }
        }
        
        jlf.intersect[i,(3 +(j-1)*207):(2 +(j)*207)] <-  as.numeric(temp.data[1,3:209])
        
        if(i == 1) {
          names(jlf.intersect)[(3 +(j-1)*207):(2 +(j)*207)] <- names(temp.data[,3:209])
        }
        
      }   
    }
  }
  print(i)
}

names(jlf.intersect)[1:2] <- c("bblid","scanid")

index <- 0
for (i in 1:2500) {
  if (all(is.na(jlf.intersect[,i]))) {
    index <- c(index, i)
  }
}

index <- index[-1]
jlf.intersect <- jlf.intersect[,-index]

write.csv(jlf.intersect, "/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_jlf_intersect_roivals.csv", row.names=F)



##Ravens 
data1 <- read.csv("/data/joy/BBL/projects/pncReproc2015/ravens/N1601_Ravens_QA.csv")

data1$path <- ""

for (i in 1:1601) {
  data1$path[i] <- paste0("/data/joy/BBL/studies/pnc/n2416_dataFreezeJan2017/neuroimaging/t1struct/voxelwiseMaps_ravens/*_",data1$scanid[i],"_*")
}

data1 <- as.data.frame(data1$path)


write.csv(data1, "/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/voxelwiseMaps_ravens/paths.csv", row.names=F, quote=F)

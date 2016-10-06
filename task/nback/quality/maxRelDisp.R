#!/usr/bin/env Rscript

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################

relrms <- read.csv('RELRMS.csv')
for (i in 1:dim(relrms)[1]){
   tmp <- read.csv(as.character(relrms$rmsPath[i]))
   relrms$nbackMaxRelRMS[i] <- max(tmp)
}
write.csv(relrms,'MAXRELRMS.csv')

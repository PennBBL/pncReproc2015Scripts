#!/usr/bin/env Rscript

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################

require(pracma)
require(ANTsR)
suppressMessages(require(ggplot2))
mask <- antsImageRead('tstatSigchangeNbackThr.nii.gz',3)
contrasts <- read.csv('contrast2-0paths.csv',header=FALSE)
nsubj <- dim(contrasts)[1]
for (i in 1:nsubj) {
   conpath <- contrasts[i,3]
   con <- antsImageRead(as.character(conpath),3)
   contrasts$mean[i] <- mean(con[as.logical(as.array(mask))])
}

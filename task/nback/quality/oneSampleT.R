#!/usr/bin/env Rscript

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################

require(pracma)
require(ANTsR)
mgd <- antsImageRead('mergedSigchangeContrastNback.nii.gz',4)
mask <- antsImageRead('maskNbackVoxelwiseCoverage.nii.gz',3)
outpath <- 'tstatSigchangeNback.nii.gz'

nsubj <- dim(mgd)[4]

mgd <- mgd[as.logical(as.array(mask)),]
dim(mgd) <- c(sum(as.logical(as.array(mask))),nsubj)

tval <- vector('numeric',length=nsubj)
pval <- vector('numeric',length=nsubj)

for (i in 1:dim(mgd)[1]) {
   tmp <- t.test(mgd[i,])
   tval[i] <- tmp$statistic
   pval[i] <- tmp$p.value
}

tval.thr <- tval
pval.adj <- p.adjust(pval, method = 'bonferroni', n = length(pval))
pidx <- which(pval.adj >= 0.01)
tval.thr[pidx] <- 0

out <- array(0,dim=dim(mask))
out[as.logical(as.array(mask))] <- tval.thr
out <- as.antsImage(out)
antsCopyImageInfo(mask,out)
antsImageWrite(out,outpath)

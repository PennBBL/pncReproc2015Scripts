# wrapper for prior renormalisation

suppressMessages(library('ANTsR'))

source('renormalizePriorsPreserveCSF.R')

priors <- list(6)
priors[1] <- '/data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/kmeans/kmeansPosterior01.nii.gz'
priors[2] <- '/data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/prior2.nii.gz'
priors[3] <- '/data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/prior3.nii.gz'
priors[4] <- '/data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/prior4.nii.gz'
priors[5] <- '/data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/prior5.nii.gz'
priors[6] <- '/data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/prior6.nii.gz'

i <- 1
for (pr in priors) {
  priors[i] <- antsImageRead(pr,3)
  i <- i + 1
}

mask <- '/data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029/templateMask.nii.gz'
mask <- antsImageRead(mask,3)

outpath <- '/data/jag/BBL/projects/pncReproc2015/template/priors/renorm/'

renormalizePriorsPreserveCSF(mask=mask,priorImages=priors,outputRoot=outpath)
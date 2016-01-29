writeImages <- function(images, outputRoot) {

 for (i in 1:length(images)) {
   antsImageWrite(images[[i]], paste(outputRoot, sprintf("%03d", i), ".nii.gz", sep=""))
 }

}


renormalizePriorsPreserveCSF <- function(mask=NULL, priorImages = NULL, outputRoot=NULL) {

 if (is.null(mask)) {

   cat("Required parameters:

      mask - Binary brain mask image (see getMask). Anything in the mask that has label 0 is assumed to be CSF.

      priorImages - list of images containing the priors, in class order. The CSF must be class 1

      outputRoot - Root path to output.

      Produces : outputRootprior_00[1-N].nii.gz where there are N classes in priorImages
 
        Class 1 (CSF) probability is taken from csfPriorImage. Probabilities for classes 2-N are scaled so that
        all probabilities sum to 1. For example, if the CSF prior probability is 0.4, and the MALF GM probability
        is 1, the output probability for GM will be 0.6.

   ")

   return()
 }

 numVoxels <- length(which(mask > 0))

 csfPrior <- priorImages[[1]][mask > 0]

 numClasses <- length(priorImages)
 
 labelProbs <- vector("list", numClasses)

 # We normalize the label probs so that CSF (from segmentation) + other classes (from MALF) sum to 1
 nonCSF_Total <- 1 - csfPrior

 priors <- matrix(nrow = numClasses, ncol = numVoxels)

 priors[1, ] <- csfPrior

 for (c in 2:numClasses) {

   priors[c, ] <- priorImages[[c]][mask > 0]

 }

 sumNonCSF <- colSums(priors[2:numClasses,])

 # If there's 0 probability of anything else, set CSF prior to 1
 priors[1,which(sumNonCSF == 0)] = 1

 # Avoid divide by zero below
 sumNonCSF[which(sumNonCSF == 0)] <- 1

 # Renormalize
 for (c in 2:numClasses) {
   priors[c,] <- nonCSF_Total * priors[c,] / sumNonCSF
 }

 writeImages(matrixToImages(priors, mask),  paste(outputRoot, "prior_", sep=""))

}


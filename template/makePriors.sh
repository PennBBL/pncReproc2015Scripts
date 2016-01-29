#makes final template images including mask, brain extracted templatel, and priors
#smooths JLF segmentation of template to make all tissue priors except CSF
jifTemplate=/data/jag/BBL/projects/pncReproc2015/template/jifTemplate/jifTemplate_20151021.nii.gz
jlfDir=/data/jag/BBL/projects/pncReproc2015/template/jlfOasis
outDir=/data/jag/BBL/projects/pncReproc2015/template/pncTemplate_20151029
segImgIn=$jlfDir/jlfLabels.nii.gz

#copy jif template over final directory
if [ ! -e "$outDir/template.nii.gz" ]; then
	echo "copying JIF template to final template directory"
	cp $jifTemplate $outDir/template.nii.gz
	cp $segImgIn $outDir/templateSeg.nii.gz
fi

templateHead=$outDir/template.nii.gz
segImg=$outDir/templateSeg.nii.gz

#make brain mask
if [ ! -e "$outDir/templateMask.nii.gz" ]; then
	echo "making brain mask and templateBrain"
	ThresholdImage 3 $segImg $outDir/templateMask.nii.gz 1 6
	fslmaths $templateHead -mas $outDir/templateMask $outDir/templateBrain.nii.gz
fi

templateBrain=$outDir/templateBrain.nii.gz
templateMask=$outDir/templateMask.nii.gz

#make priors
priorNum=(2 3 4 5 6 ) 
if [ ! -e "$outDir/prior6.nii.gz" ]; then
	echo "making priors 2-6"
	for i in "${priorNum[@]}"; do  
		echo ""
		echo $i
		ThresholdImage 3 $segImg $jlfDir/binary_${i}.nii.gz $i $i
		SmoothImage 3 $jlfDir/binary_${i}.nii.gz 1.0 $outDir/prior${i}.nii.gz
	done
fi

#run K means on brain template to get CSF 
if [ ! -d "$outDir/kmeans" ]; then
	mkdir $outDir/kmeans
fi

if [ ! -e "$outDir/kmeans/outDir/kmeans/kmeansSeg.nii.gz" ] ; then
	echo "running Atropos"
	Atropos -d 3 -a $templateBrain -i KMeans[3] -o [$outDir/kmeans/kmeansSeg.nii.gz,$outDir/kmeans/kmeansPosterior%02d.nii.gz] -v -x $templateMask 
fi


#still have to normalize this csf 
#jlf$probimgs[[ 1 ]] = kMeansCSFprobability # alternatively might smooth then normalize to [0,1]
#  newprobimgs2 = renormalizeProbabilityImages(
#   jlf$probimgs, brainmask, 1 )

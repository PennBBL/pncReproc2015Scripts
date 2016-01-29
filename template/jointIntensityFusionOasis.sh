#creates joint intensity fusion template 

jlfTarget=/data/jag/BBL/projects/pncReproc2015/template/jifTemplate/jifTemplate_20151021.nii.gz
outDir=/data/jag/BBL/projects/pncReproc2015/template/jlfOasis/
jifCall=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/template/callJifOasis.sh

export ANTSDIR=/data/jag/BBL/applications/ants_20151007/bin


#assemble list of images and labels for jlf call
rm -f $jifCall
params=" -r 1 -v 1 -s 2 -p 2 -a 0.05 -b 4 -c 0 "
echo -n "$ANTSDIR/antsJointFusion -v -d 3 -r -t $jlfTarget  -o [$outDir/jlfLabels.nii.gz,$outDir/jlfIntensity.nii.gz,$outDir/jlf_Posteriors%02d.nii.gz]" >> $jifCall


#get warped image and label for each registered oasis image
imgs=$(ls $outDir/jlf*_Warped.nii.gz)
for img in $imgs; do 
	echo ""
	echo "****"
	echo $img
	#fslinfo $img
	id=$(basename $img | cut -d_ -f1)
	
	echo""
	labelImg=$(ls $outDir/${id}*WarpedLabels.nii.gz)
	echo $labelImg
#	fslinfo $labelImg
	echo -n " -g $img -l $labelImg" >> $jifCall
done

chmod +x $jifCall
qsub -V -b y -j y -m beas -M sattertt@upenn.edu -l h_vmem=20.5G,s_vmem=20G -cwd $jifCall

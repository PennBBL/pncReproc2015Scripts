#creates joint intensity fusion template 

btpDir=/data/jag/BBL/projects/pncReproc2015/template/initialTemplate2/
inputTemplate=/data/jag/BBL/projects/pncReproc2015/template/initialTemplate2/initialTemplate2template.nii.gz
outDir=/data/jag/BBL/projects/pncReproc2015/template/jifTemplate
jifCall=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/template/callJif.sh
export ANTSDIR=/data/jag/BBL/applications/ants_20151007/bin

#pad template
if [ ! -e "$outDir/initialTemplate2template_padded.nii.gz" ]; then
	echo "padding initial BTP tempalte"
	$ANTSDIR/ImageMath 3 $outDir/initialTemplate2template_padded.nii.gz PadImage $inputTemplate 5
else
	echo "padded template present"
fi

#generate intensity only images
echo ""
lastImg=/data/jag/BBL/projects/pncReproc2015/template/initialTemplate2/initialTemplate297994_20100923x3846_t1deformed_normalized_padded.nii.gz
if [ ! -e "$lastImg" ]; then
	echo "normalizing and padding warped images"
	warpedImages=$(ls $btpDir/*t1deformed.nii.gz)
	for x in $warpedImages; do 
		echo "working on $x"
		imgName=$(echo $x | cut -d. -f1)
		$ANTSDIR/ImageMath 3 ${imgName}_normalized.nii.gz Normalize $x
		$ANTSDIR/ImageMath 3 ${imgName}_normalized_padded.nii.gz PadImage ${imgName}_normalized.nii.gz 5
	done
else
	echo "warped images padded and normalized already"
fi

#assemble list of images for jlf call
rm -f $jifCall
echo -n "$ANTSDIR/antsJointFusion -v -d 3 -t $outDir/initialTemplate2template_padded.nii.gz -o $outDir/jifTemplate.nii.gz" >> $jifCall
imgs=$(ls $btpDir/*_normalized_padded.nii.gz)
for i in $imgs; do 
	echo -n " -g $i" >> $jifCall
done

chmod +x $jifCall
qsub -V -b y -j y -m beas -M sattertt@upenn.edu -l h_vmem=20.5G,s_vmem=20G -cwd $jifCall

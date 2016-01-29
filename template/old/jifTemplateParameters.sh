export ANTSDIR=/data/jag/BBL/applications/ants_20151007/bin
init=/data/jag/BBL/projects/pncReproc2015/template/jifTemplate/initialTemplate2template_padded.nii.gz
wd=/data/jag/BBL/projects/pncReproc2015/template/jifTemplate/twoD
btpDir=/data/jag/BBL/projects/pncReproc2015/template/initialTemplate2/

cd $wd
pwd

#get a 2D slice and normalize template
$ANTSDIR/ExtractSliceFromImage 3 $init  init.nii.gz 2 86
$ANTSDIR/ImageMath 2 ref.nii.gz Normalize init.nii.gz
ref=ref.nii.gz


#pad images
warpedImages=$(ls $btpDir/*t1deformed.nii.gz)
for x in $warpedImages; do
		echo "working on $x"
		imgName=$(echo $x | cut -d. -f1)
		$ANTSDIR/ImageMath 3 ${imgName}_padded.nii.gz PadImage $x 5
done

#get slices
imgs=$(ls $btpDir/*t1deformed_padded.nii.gz)
for i in $imgs; do
        imgName=$(basename $i | cut -d. -f1)
	echo $imgName
	$ANTSDIR/ExtractSliceFromImage 3 $i  $wd/${imgName}_slice.nii.gz 2 86
done


#histogram match
slices=$(ls $wd/*slice.nii.gz)
for x in $slices; do
	echo $x
        imgName=$(basename $x | cut -d. -f1)
  	$ANTSDIR/ImageMath 2 ${imgName}_matched.nii.gz HistogramMatch ${x}  $ref
done

intensityImages=$(ls $wd/*matched.nii.gz)
params=" -r 1 -v 1 -s 2 -p 2 -a 0.05 -b 4 " # parameters should be explicit
commandLine="$ANTSDIR/antsJointFusion -d 2 --verbose 0  -t $ref -o  testIntensity.nii.gz
   $params -c 0 "

for (( i = 0; i < ${#intensityImages[@]}; i++ )); do
    commandLine="${commandLine} -g ${intensityImages[$i]}"
done

#run JF w/ above params
$commandLine

#sharpening
$ANTSDIR/ImageMath 2 testIntensityS.nii.gz Sharpen testIntensity.nii.gz
# but overdoes it so we re-average w/unsharpened data ....
$ANTSDIR/ImageMath 2 testIntensityS.nii.gz + testIntensityS.nii.gz testIntensity.nii.gz
# testIntensityS gives a "fair" comparison to BTP output

# now some positivity restriction ( takes *much* longer to compute )
commandLine="$ANTSDIR/antsJointFusion -d 2 --verbose 0  -t $ref -o  testIntensityP.nii.gz
  $params -c 1 "
for (( i = 0; i < ${#intensityImages[@]}; i++ ))
  do
    commandLine="${commandLine} -g ${intensityImages[$i]}"
  done

$commandLine


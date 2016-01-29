wd=/data/jag/BBL/projects/pncReproc2015/template/jifTemplate/
jifTemplate=$wd/jifTemplate_20151021.nii.gz
ANTSDIR=/data/jag/BBL/applications/ants_20151007/bin/

$ANTSDIR/ImageMath 3 $wd/jifTempalteSharpenedTmp.nii.gz Sharpen $jifTemplate
$ANTSDIR/ImageMath 3 $wd/jifTempalteSharpened.nii.gz + $wd/jifTempalteSharpenedTmp.nii.gz $jifTemplate



imgDir=/data/jag/BBL/projects/pncReproc2015/template/images/
ANTSDIR=/data/jag/BBL/applications/bbl_ants2/bin/

cd $imgDir
pwd
$ANTSDIR/buildtemplateparallel.sh -d 3 -z /data/jag/BBL/projects/pncReproc2015/template/initialTemplate1/initialTemplate1template.nii.gz -o initialTemplate2  *t1.nii.gz 


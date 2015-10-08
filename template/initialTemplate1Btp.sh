imgDir=/data/jag/BBL/projects/pncReproc2015/template/images/
ANTSDIR=/data/jag/BBL/applications/bbl_ants2/bin/

cd $imgDir
pwd
$ANTSDIR/buildtemplateparallel.sh -d 3 -m 1x1x0 -r 1  -c 1 -o initialTemplate1  *t1.nii.gz


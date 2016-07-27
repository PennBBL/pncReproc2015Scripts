export FREESURFER_HOME="/share/apps/freesurfer/5.3.0"
export PERL5LIB="/share/apps/freesurfer/5.3.0/mni/lib/perl5/5.8.5"

subjid=$1
templateid=$2
SUBJECTS_DIR=$3

cd $SUBJECTS_DIR

recon-all -long $subjid $templateid -all

export FREESURFER_HOME="/share/apps/freesurfer/5.3.0"
export PERL5LIB="/share/apps/freesurfer/5.3.0/mni/lib/perl5/5.8.5"

subjid1=$1
subjid2=$2
subjid3=$3
tmpid=$4
SUBJECTS_DIR=$5

recon-all -base $tmpid -tp $subjid1 -tp $subjid2 -tp $subjid3 -all




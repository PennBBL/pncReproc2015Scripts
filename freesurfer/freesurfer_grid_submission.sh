#!/bin/bash
. /etc/bashrc
export FREESURFER_HOME="/share/apps/freesurfer/5.3.0"
export SUBJECTS_DIR=$2
export PERL5LIB="/share/apps/freesurfer/5.3.0/mni/lib/perl5/5.8.5"

mprage=$1
subjid=$3

#echo $mprage
recon-all -i $mprage -subjid $subjid  ## run this to set up each subject's FS directory 
recon-all -subjid $subjid -all -qcache  ## after running intial set up 

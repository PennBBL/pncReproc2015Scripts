export FREESURFER_HOME="/share/apps/freesurfer/5.3.0" 
export SUBJECTS_DIR="/data/joy/BBL/studies/pnc/processedData/structural/freesurfer53" 
export QA_TOOLS="/data/joy/BBL/applications/QAtools_v1.1/" 

#make variables with the subject list for each person 
slist_PV="/data/joy/BBL/projects/pncReproc2015/freesurfer/FsQaManualReview/PVManualQaList.csv"
slist_JB="/data/joy/BBL/projects/pncReproc2015/freesurfer/FsQaManualReview/JBManualQaList.csv"
slist_KS="/data/joy/BBL/projects/pncReproc2015/freesurfer/FsQaManualReview/KSManualQaList.csv"


#for subject list (rater), output the snapshots into a single subject html file in their folder. 

#PV

#loop through the subject list
for i in `cat $slist_PV`; do 

#create a variable with gets the bblid and datexscanid for each subject iteration
bblid=`echo $i | cut -d "/" -f 1`;
datexscanid=`echo $i | cut -d "/" -f 2`;

#create a variable that gets the subject specific (bblid specific) subjects dir for that subject
export SUBJECTS_DIR="/data/joy/BBL/studies/pnc/processedData/structural/freesurfer53/"$bblid 

#run the script to output a snapshot html file in each rater's directory, each firefox file will be named with the bblid and datexscanid
echo "$QA_TOOLS/recon_checker -s $datexscanid -snaps-out "/data/joy/BBL/projects/pncReproc2015/freesurfer/FsQaManualReview/PV_snapshots/"$bblid"_"$datexscanid".html" -snaps-only -snaps-overwrite"

done

#JB

#loop through the subject list
for i in `cat $slist_JB`; do 

#create a variable with gets the bblid and datexscanid for each subject iteration
bblid=`echo $i | cut -d "/" -f 1`;
datexscanid=`echo $i | cut -d "/" -f 2`;

#create a variable that gets the subject specific (bblid specific) subjects dir for that subject
export SUBJECTS_DIR="/data/joy/BBL/studies/pnc/processedData/structural/freesurfer53/"$bblid 

#run the script to output a snapshot html file in each rater's directory, each firefox file will be named with the bblid and datexscanid
$QA_TOOLS/recon_checker -s $datexscanid -snaps-out "/data/joy/BBL/projects/pncReproc2015/freesurfer/FsQaManualReview/JB_snapshots/"$bblid"_"$datexscanid".html" -snaps-only -snaps-overwrite

done


#KS

#loop through the subject list
for i in `cat $slist_KS`; do 

#create a variable with gets the bblid and datexscanid for each subject iteration
bblid=`echo $i | cut -d "/" -f 1`;
datexscanid=`echo $i | cut -d "/" -f 2`;

#create a variable that gets the subject specific (bblid specific) subjects dir for that subject
export SUBJECTS_DIR="/data/joy/BBL/studies/pnc/processedData/structural/freesurfer53/"$bblid 

#run the script to output a snapshot html file in each rater's directory, each firefox file will be named with the bblid and datexscanid
$QA_TOOLS/recon_checker -s $datexscanid -snaps-out "/data/joy/BBL/projects/pncReproc2015/freesurfer/FsQaManualReview/KS_snapshots/"$bblid"_"$datexscanid".html" -snaps-only -snaps-overwrite

done



#this is residual code that doesn't work, it was supposed to be able to get a subject list file and create all of the snapshots in one html file, but unfortunately doesn't work. I believe because of the directory structure on CFN for freesurfer (each bblid has their own subjects dir technically)
#$QA_TOOLS/recon_checker -s-file $slist_PV -snaps-out "/data/joy/BBL/projects/pncReproc2015/freesurfer/FsQaManualReview/FsQaSnapshotsPV.html" -snaps-only


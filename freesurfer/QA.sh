#!/bin/bash
#######################################
############# QA Pipeline #############
#######################################

#Runs the quality assurance pipeline for FreeSurfer 5.3 on CFN and outputs several csv's with subject specific QA data. The code is broken down into seven main sections:
 # Create subcortical volume segmentation csv - aseg stats
 # Create mean QA data charts (thickness and surface area charts)
 # Create parcellation csv's - aparc stats
 # Create CNR and Euler Numbers csv's 
 # Flag subjects based on whether they are an outlier (>2 SD) on at least one of the following measures:
  # Mean thickness
  # Total surface area
  # Cortical volume
  # Subcortical gray matter
  # Cortical White matter
  # CNR 
  # Euler number
  # SNR
  # ROI- Raw cortical thickness
  # ROI- laterality thickness difference
 # Flag  (gray/csf flag, gray/white flag, euler number flag, number outliers rois thickness flag, total outliers)
 # Create SNR csv
########################################
# This script calls: 
    # /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurfer/aparc.stats.meanthickness.totalarea.sh
    # /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurfer/cnr_euler_number_calculation.sh
    # /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurfer/flag_outliers.R  
    # /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurfer/cnr_euler_qa.R
########################################

#Set variables
#slist=/data/joy/BBL/studies/pnc/subjectData/freesurfer/go1_go2_freesurfer53_qa_run_list.txt
slist=/data/joy/BBL/studies/pnc/subjectData/freesurfer/go1_go2_go3_freesurfer53_qa_run_list.txt
export output_dir=/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3
export SUBJECTS_DIR=/data/joy/BBL/studies/pnc/processedData/structural/freesurfer53
export QA_TOOLS=/data/joy/BBL/applications/QAtools_v1.1/
export FREESURFER_HOME=/share/apps/freesurfer/5.3.0/
export PATH=$FREESURFER_HOME/bin/:$PATH

##### 1) Create subcortical volume segmentation csv - aseg stats##### 
if [ ! -e "$output_dir/aseg.stats" ]; then
	mkdir -p $output_dir/aseg.stats
fi
asegstats2table --subjectsfile=$slist -t $output_dir/aseg.stats/aseg.stats.volume.csv -m volume --skip

##### 2) Create mean QA data charts (thickness and surface area charts)##### 
/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurfer/aparc.stats.meanthickness.totalarea.sh $slist $output_dir $SUBJECTS_DIR 

##### 3) Create parcellation csv's - aparc stats##### 
aparcstats2table --hemi lh --subjectsfile=$slist -t $output_dir/aparc.stats/lh.aparc.stats.thickness.csv -m thickness --skip
aparcstats2table --hemi rh --subjectsfile=$slist -t $output_dir/aparc.stats/rh.aparc.stats.thickness.csv -m thickness --skip
aparcstats2table --hemi lh --subjectsfile=$slist -t $output_dir/aparc.stats/lh.aparc.stats.volume.csv -m volume --skip
aparcstats2table --hemi rh --subjectsfile=$slist -t $output_dir/aparc.stats/rh.aparc.stats.volume.csv -m volume --skip
aparcstats2table --hemi lh --subjectsfile=$slist -t $output_dir/aparc.stats/lh.aparc.stats.area.csv --skip
aparcstats2table --hemi rh --subjectsfile=$slist -t $output_dir/aparc.stats/rh.aparc.stats.area.csv --skip

##### 4) Create CNR and Euler Numbers csv's##### 
/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurfer/cnr_euler_number_calculation.sh $slist $SUBJECTS_DIR $output_dir

##### 5) Flag subjects based on whether they are an outlier (>2 SD) on several measures##### 
/share/apps/R/R-3.1.1/bin/R --slave --file=/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurfer/flag_outliers.R --args $output_dir

##### 6) Flag  (gray/csf flag, gray/white flag, euler number flag, number outliers rois thickness flag, total outliers)##### 
/share/apps/R/R-3.1.1/bin/R --slave --file=/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurfer/cnr_euler_qa.R --args $output_dir

##### 7) Create SNR csv##### 
#run QA tools recon checker on each subject
for i in $(cat $slist); do
	$QA_TOOLS/recon_checker -s $i -nocheck-aseg -nocheck-status -nocheck-outputFOF -no-snaps 
done > temp.txt

#grep for the subject IDs and output into temp2.txt
grep "wm-anat-snr results" temp.txt | cut -d"(" -f2 | cut -d")" -f1 >temp2.txt

#loop through each bblid in temp.txt, and pull the snr value from temp.txt and output to temp3.txt 
for i in $(cat -n temp.txt | grep "wm-anat-snr results" | cut -f1); do
	echo $(sed -n "$(echo $i +2 | bc)p" temp.txt | cut -f1)
done > temp3.txt

#append each subject's snr data into the snr.txt file
paste temp2.txt temp3.txt > $output_dir/cnr/snr.txt

#remove temporary files
rm -f temp*.txt



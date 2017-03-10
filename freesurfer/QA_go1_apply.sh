#!/bin/bash
#######################################
############# QA Pipeline #############
#######################################

#Runs the quality assurance pipeline for FreeSurfer 5.3 on CFN and outputs several csv's with subject specific QA data. The code is broken down into seven main sections:
 # Create subcortical volume segmentation csv - aseg stats
 # Create mean QA data charts (thickness and surface area charts)
 # Create parcellation csv's - aparc stats
 # Create CNR and Euler Numbers csv's 
 # Flag subjects based on whether they are a GO1 outlier (>2 SD) after excluding manual qa 0 on at least one of the following measures:
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
    # /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/freesurfer/aparc.stats.meanthickness.totalarea.sh
    # /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/freesurfer/cnr_euler_number_calculation.sh
    # /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/freesurfer/flag_outliers_go1_apply.R  
    # /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/freesurfer/cnr_euler_qa_go1_apply.R
########################################

#Set variables
slist=/data/joy/BBL/studies/pnc/subjectData/freesurfer/go1_go2_go3_freesurfer53_qa_run_list_n2496.txt
#slist=/data/joy/BBL/studies/pnc/subjectData/freesurfer/go1_go2_go3_freesurfer53_qa_run_list_n2416.txt
#slist=/data/joy/BBL/studies/pnc/subjectData/freesurfer/go_freesurfer53_qa_run_list_n1601.txt
export output_dir=/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3
export SUBJECTS_DIR=/data/joy/BBL/studies/pnc/processedData/structural/freesurfer53
export QA_TOOLS=/data/joy/BBL/applications/QAtools_v1.1/
export FREESURFER_HOME=/share/apps/freesurfer/5.3.0/
export PATH=$FREESURFER_HOME/bin/:$PATH

#the standard deviation threshold at which you would like to flag the ROI data
sdthresh=2

#give it the subject n that you wish to be appended to each file name
subjnum="n2496"

#a list of go1 subjects so can use for flagging outliers based on go1
go1_list=/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv

#a list of the manual qa so can exclude 0's first
t1_qa=/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_t1QaData_20170306.csv

#demographics data 
demos=/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_073015.csv

##### 1) Create subcortical volume segmentation csv - aseg stats##### 
if [ ! -e "$output_dir/aseg.stats" ]; then
	mkdir -p $output_dir/aseg.stats
fi
asegstats2table --subjectsfile=$slist -t $output_dir/aseg.stats/"$subjnum"_aseg.stats.volume.csv -m volume --skip

##### 2) Create mean QA data charts (thickness and surface area charts)##### 
/home/mquarmley/pncReproc2015Scripts/freesurfer/aparc.stats.meanthickness.totalarea.sh $slist $output_dir $SUBJECTS_DIR $subjnum

##### 3) Create parcellation csv's - aparc stats##### 
aparcstats2table --hemi lh --subjectsfile=$slist -t $output_dir/aparc.stats/"$subjnum"_lh.aparc.stats.thickness.csv -m thickness --skip
aparcstats2table --hemi rh --subjectsfile=$slist -t $output_dir/aparc.stats/"$subjnum"_rh.aparc.stats.thickness.csv -m thickness --skip
aparcstats2table --hemi lh --subjectsfile=$slist -t $output_dir/aparc.stats/"$subjnum"_lh.aparc.stats.volume.csv -m volume --skip
aparcstats2table --hemi rh --subjectsfile=$slist -t $output_dir/aparc.stats/"$subjnum"_rh.aparc.stats.volume.csv -m volume --skip
aparcstats2table --hemi lh --subjectsfile=$slist -t $output_dir/aparc.stats/"$subjnum"_lh.aparc.stats.area.csv --skip
aparcstats2table --hemi rh --subjectsfile=$slist -t $output_dir/aparc.stats/"$subjnum"_rh.aparc.stats.area.csv --skip

##### 4) Create CNR and Euler Numbers csv's##### 
/home/mquarmley/pncReproc2015Scripts/freesurfer/cnr_euler_number_calculation.sh $slist $SUBJECTS_DIR $output_dir $subjnum

##### 5) Flag subjects based on whether they are an outlier (>2 SD) on several measures##### 
/share/apps/R/R-3.2.3/bin/R --slave --file=/home/mquarmley/pncReproc2015Scripts/freesurfer/flag_outliers_go1_apply.R --args $output_dir $go1_list $sdthresh $t1_qa $subjnum

##### 6) Flag  (gray/csf flag, gray/white flag, euler number flag, number outliers rois thickness flag, total outliers)##### 
/share/apps/R/R-3.2.3/bin/R --slave --file=/home/mquarmley/pncReproc2015Scripts/freesurfer/cnr_euler_qa_go1_apply.R --args $output_dir $go1_list $t1_qa $subjnum $demos

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
paste temp2.txt temp3.txt > $output_dir/cnr/"$subjnum"_snr.txt

#remove temporary files
rm -f temp*.txt


#Run script to input the flagged subject csv's and determine is the subject is flagged for automatic FS QA and should be manually reviewed. This script also will output the total number of flags per outlier into a csv table.

go1_flag=$output_dir/all.flags.go1.based."$subjnum".csv
euler_flag=$output_dir/cnr_euler_flags_go1_based_"$subjnum".csv

/share/apps/R/R-3.2.3/bin/R --slave --file=/home/mquarmley/pncReproc2015Scripts/freesurfer/sum_flags_auto_qa_for_manual_review.R --args $output_dir $subjnum $go1_flag $euler_flag $t1_qa






